//
//  Untitled.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//

import Foundation
import Speech
import AVFoundation

@MainActor
@Observable
class SpeechToTextViewModel {

    // 1.
    private(set) var model = TranscriptionModel()
    private(set) var errorMessage: String?
    private let audioManager = AudioManager()
    private let transcriptionManager = TranscriptionManager()


    // 2.
    private func requestPermissions() async -> Bool {
        let speechPermission = await transcriptionManager.requestSpeechPermission()
        let micPermission = await audioManager.requestMicrophonePermission()
        return speechPermission && micPermission
    }
    
    // 3.
    func toggleRecording() {
        if model.isRecording {
            Task { await stopRecording() }
        } else {
            Task { await startRecording() }
        }
    }

    // 4.
    func clearTranscript() {
        model.finalizedText = ""
        model.currentText = ""
        errorMessage = nil
    }

    // 5.
    private func startRecording() async {
        guard await requestPermissions() else {
            errorMessage = "Permissions not granted"
            return
        }
        
        do {
            try audioManager.setupAudioSession()
            
            try await transcriptionManager.startTranscription { [weak self] text, isFinal in
                Task { @MainActor in
                    guard let self = self else { return }
                    if isFinal {
                        self.model.finalizedText += text + " "
                        self.model.currentText = ""
                    } else {
                        self.model.currentText = text
                    }
                }
            }
            
            try audioManager.startAudioStream { [weak self] buffer in
                try? self?.transcriptionManager.processAudioBuffer(buffer)
            }
            
            model.isRecording = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 6.
    private func stopRecording() async {
        audioManager.stopAudioStream()
        await transcriptionManager.stopTranscription()
        model.isRecording = false
    }

}


