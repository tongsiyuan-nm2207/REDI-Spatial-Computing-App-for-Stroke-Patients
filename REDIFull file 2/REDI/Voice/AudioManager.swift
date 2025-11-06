//
//  AudioManager.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 27/10/25.
//

import Foundation
import AVFoundation

class AudioManager {

    // 1. Core audio components
    private let audioEngine = AVAudioEngine()
    private var audioTapInstalled = false
    private let audioSession = AVAudioSession.sharedInstance()
    
    // 2. Setup audio session optimized for speech recognition
    func setupAudioSession() throws {
        // Configure for optimal speech recognition
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Set preferred sample rate for better recognition
        try audioSession.setPreferredSampleRate(44100)
        
        // Configure for minimal latency
        try audioSession.setPreferredIOBufferDuration(0.005)
    }

    // 3. Request microphone permission
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // 4. Start audio streaming with better error handling
    func startAudioStream(onBuffer: @escaping (AVAudioPCMBuffer) -> Void) throws {
        // Prevent duplicate tap installation
        guard !audioTapInstalled else {
            print("Audio tap already installed")
            return
        }
        
        // Get the input node and its output format
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Validate format
        guard recordingFormat.sampleRate > 0 else {
            throw AudioError.invalidFormat
        }
        
        // Install tap with appropriate buffer size
        inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: recordingFormat
        ) { buffer, _ in
            // Process buffer on background queue
            DispatchQueue.global(qos: .userInteractive).async {
                onBuffer(buffer)
            }
        }
        
        // Prepare and start the audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        audioTapInstalled = true
        print("Audio streaming started successfully")
    }

    // 5. Stop audio streaming with cleanup
    func stopAudioStream() {
        guard audioTapInstalled else {
            print("No audio tap to remove")
            return
        }
        
        // Stop the engine
        audioEngine.stop()
        
        // Remove the tap
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Reset the flag
        audioTapInstalled = false
        
        // Deactivate audio session to allow other apps to use audio
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        
        print("Audio streaming stopped")
    }
    
    // 6. Handle audio session interruptions
    func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began - pause recording if needed
            if audioEngine.isRunning {
                audioEngine.pause()
            }
            
        case .ended:
            // Interruption ended - resume if appropriate
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    try? audioEngine.start()
                }
            }
            
        @unknown default:
            break
        }
    }
    
    // 7. Cleanup
    deinit {
        if audioTapInstalled {
            stopAudioStream()
        }
    }
}

// Custom error types
enum AudioError: Error {
    case invalidFormat
    case engineNotRunning
    case tapAlreadyInstalled
    
    var localizedDescription: String {
        switch self {
        case .invalidFormat:
            return "Invalid audio format"
        case .engineNotRunning:
            return "Audio engine is not running"
        case .tapAlreadyInstalled:
            return "Audio tap is already installed"
        }
    }
}


