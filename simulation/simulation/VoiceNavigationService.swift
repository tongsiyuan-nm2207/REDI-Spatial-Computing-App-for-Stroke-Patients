//
//  VoiceNavigationService.swift
//  simulation
//
//  Created by Interactive 3D Design on 28/9/25.
//

import SwiftUI
import Speech
import AVFoundation
import Combine

// MARK: - Voice Navigation Service
class VoiceNavigationService: ObservableObject {
    @Published var recognizedText = ""
    @Published var isListening = false
    @Published var errorMessage = ""
    @Published var shouldNavigate = false // This will trigger navigation in ContentView
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.defaultTaskHint = .search
        requestPermissions()
    }
    
    func startListening() {
        // Reset navigation trigger
        shouldNavigate = false
        
        // Stop any existing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Audio session configuration failed: \(error.localizedDescription)"
            }
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            DispatchQueue.main.async {
                self.errorMessage = "Unable to create recognition request"
            }
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isListening = true
                self.errorMessage = ""
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Audio engine failed to start: \(error.localizedDescription)"
            }
            return
        }
        
        // Start speech recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                    
                    // Check for trigger words
                    if self?.containsContinueCommand(result.bestTranscription.formattedString) == true {
                        self?.shouldNavigate = true
                        self?.stopListening()
                    }
                }
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.stopListening()
                }
            }
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionTask = nil
        recognitionRequest = nil
        
        DispatchQueue.main.async {
            self.isListening = false
        }
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error deactivating audio session: \(error.localizedDescription)"
            }
        }
    }
    
    private func containsContinueCommand(_ text: String) -> Bool {
        let lowercaseText = text.lowercased()
        let triggerWords = ["continue", "proceed", "next", "go on", "go ahead", "start"]
        
        return triggerWords.contains { word in
            lowercaseText.contains(word)
        }
    }
    
    private func requestPermissions() {
        // For visionOS compatibility
        if #available(visionOS 1.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    SFSpeechRecognizer.requestAuthorization { _ in }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    SFSpeechRecognizer.requestAuthorization { _ in }
                }
            }
        }
    }
    
    func resetNavigationTrigger() {
        shouldNavigate = false
    }
}

