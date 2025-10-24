//
//  GameSpeechManager.swift
//  Created for Cube Game Integration
//

import Foundation
import Speech
import AVFoundation
import Observation

@MainActor
@Observable
class GameSpeechManager {
    private let audioManager = AudioManager()
    private let transcriptionManager = TranscriptionManager()
    private(set) var isListening = false
    private(set) var errorMessage: String?
    
    // Game-specific properties
    var onCubeDetected: (() -> Void)?
    private var cubeDetected = false  // ADDED: Prevent multiple triggers
    
    private func requestPermissions() async -> Bool {
        let speechPermission = await transcriptionManager.requestSpeechPermission()
        let micPermission = await audioManager.requestMicrophonePermission()
        return speechPermission && micPermission
    }
    
    func startListening() async {
        guard await requestPermissions() else {
            errorMessage = "Permissions not granted"
            return
        }
        
        // ADDED: Reset detection flag when starting
        cubeDetected = false
        
        do {
            try audioManager.setupAudioSession()
            
            try await transcriptionManager.startTranscription { [weak self] text, isFinal in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    // ENHANCED: Check for "blue" in both partial AND final results for better sensitivity
                    let lowercaseText = text.lowercased()
                    print("🎙️ Transcription: '\(text)' (Final: \(isFinal))")
                    
                    if lowercaseText.contains("blue") && !self.cubeDetected {
                        self.cubeDetected = true  // Prevent multiple triggers
                        print("🎯 DETECTED 'blue' in: '\(text)' (isFinal: \(isFinal))")
                        
                        // Trigger success immediately
                        self.onCubeDetected?()
                        
                        // Stop listening immediately for fastest response
                        Task { await self.stopListening() }
                    }
                }
            }
            
            try audioManager.startAudioStream { [weak self] buffer in
                try? self?.transcriptionManager.processAudioBuffer(buffer)
            }
            
            isListening = true
            errorMessage = nil
            print("🎤 Started listening for 'blue' (enhanced sensitivity)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Speech error: \(error)")
        }
    }
    
    func stopListening() async {
        audioManager.stopAudioStream()
        await transcriptionManager.stopTranscription()
        isListening = false
        cubeDetected = false  // ADDED: Reset flag when stopping
        print("🔇 Stopped listening")
    }
}

