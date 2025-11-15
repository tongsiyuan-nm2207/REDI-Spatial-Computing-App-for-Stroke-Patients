//
//  GameSpeechManager.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 27/10/25.
//

import Foundation
import Speech
import AVFoundation
import Observation

@MainActor
@Observable
final class GameSpeechManager {

    // 1. Model and error state
    private(set) var model = TranscriptionModel()
    private(set) var errorMessage: String?
    
    // Managers
    private let audioManager = AudioManager()
    private let transcriptionManager = TranscriptionManager()
    
    // Permission flags
    private var hasPermissions = false

    // 2. Request necessary permissions
    private func requestPermissions() async -> Bool {
        let speechPermission = await transcriptionManager.requestSpeechPermission()
        let micPermission = await audioManager.requestMicrophonePermission()
        hasPermissions = speechPermission && micPermission
        return hasPermissions
    }
    
    // 3. Toggle recording with better state management
    func toggleRecording() {
        if model.isRecording {
            Task { await stopRecording() }
        } else {
            Task { await startRecording() }
        }
    }

    // 4. Clear transcript and errors
    func clearTranscript() {
        model.finalizedText = ""
        model.currentText = ""
        errorMessage = nil
    }

    // 5. Start recording with comprehensive error handling
    private func startRecording() async {
        // Check permissions first
        guard await requestPermissions() else {
            errorMessage = "Speech recognition and microphone permissions are required for this assessment."
            return
        }
        
        do {
            // Setup audio session for optimal speech recognition
            try audioManager.setupAudioSession()
            
            // Start transcription with callback
            try await transcriptionManager.startTranscription { [weak self] text, isFinal in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if isFinal {
                        // For final transcriptions, append to finalized text
                        self.model.finalizedText += text + " "
                        self.model.currentText = ""
                    } else {
                        // For interim results, update current text
                        self.model.currentText = text
                    }
                }
            }
            
            // Start audio streaming
            try audioManager.startAudioStream { [weak self] buffer in
                do {
                    try self?.transcriptionManager.processAudioBuffer(buffer)
                } catch {
                    // Log buffer processing errors but don't stop recording
                    print("Buffer processing error: \(error.localizedDescription)")
                }
            }
            
            // Update recording state
            model.isRecording = true
            errorMessage = nil
            
        } catch {
            // Handle any startup errors
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            model.isRecording = false
        }
    }

    // 6. Stop recording with proper cleanup
    private func stopRecording() async {
        // Stop audio streaming first
        audioManager.stopAudioStream()
        
        // Then stop transcription
        await transcriptionManager.stopTranscription()
        
        // Update state
        model.isRecording = false
        
        // Finalize any pending transcription
        if !model.currentText.isEmpty {
            model.finalizedText += model.currentText
            model.currentText = ""
        }
    }
}

