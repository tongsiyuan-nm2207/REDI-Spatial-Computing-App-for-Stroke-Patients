//
//  UISpeechManager.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 28/9/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class UISpeechManager {
    
    // MARK: - Published Properties
    private(set) var isListening: Bool = false
    private(set) var detectedText: String = ""
    private(set) var listeningPrompt: String = "Say 'Continue' to proceed"
    private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private var speechViewModel = SpeechToTextViewModel()
    private var onContinueDetected: (() -> Void)?
    private var continueKeywords = ["continue", "next", "proceed", "start", "go", "begin"]
    
    // MARK: - Public Methods
    func startListeningForContinue(completion: @escaping () -> Void) {
        guard !isListening else { return }
        
        self.onContinueDetected = completion
        isListening = true
        detectedText = ""
        errorMessage = nil
        listeningPrompt = "Listening... Say 'Continue'"
        
        // Clear any existing transcript and start fresh
        speechViewModel.clearTranscript()
        
        // Monitor the speech view model for changes
        Task {
            await monitorSpeechChanges()
        }
        
        // Start recording
        speechViewModel.toggleRecording()
    }
    
    func stopListening() {
        guard isListening else { return }
        
        isListening = false
        listeningPrompt = "Say 'Continue' to proceed"
        detectedText = ""
        onContinueDetected = nil
        
        // Stop recording if it's active
        if speechViewModel.model.isRecording {
            speechViewModel.toggleRecording()
        }
    }
    
    func resetForNewSession() {
        stopListening()
        speechViewModel.clearTranscript()
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func monitorSpeechChanges() async {
        // We'll check the speech model periodically
        while isListening {
            let currentText = speechViewModel.model.displayText.lowercased()
            detectedText = speechViewModel.model.displayText
            
            // Check for error messages
            if let error = speechViewModel.errorMessage {
                errorMessage = error
                stopListening()
                break
            }
            
            // Check if any continue keywords are detected
            if containsContinueKeyword(in: currentText) {
                listeningPrompt = "Continue detected! ✓"
                
                // Small delay to show the confirmation
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Trigger the completion
                onContinueDetected?()
                stopListening()
                break
            }
            
            // Small delay between checks
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
    
    private func containsContinueKeyword(in text: String) -> Bool {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
        
        return continueKeywords.contains { keyword in
            words.contains { word in
                word.lowercased().contains(keyword)
            }
        }
    }
}

