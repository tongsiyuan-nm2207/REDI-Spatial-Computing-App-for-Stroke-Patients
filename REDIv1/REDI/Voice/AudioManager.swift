//
//  AudioManager.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//


import Foundation
import AVFoundation

class AudioManager {
    private let audioEngine = AVAudioEngine()
    private var audioTapInstalled = false

    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startAudioStream(onBuffer: @escaping (AVAudioPCMBuffer) -> Void) throws {
        guard !audioTapInstalled else { return }
        
        // Use smaller buffer size for better sensitivity - simple approach like your original
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 1024, // Reduced from 4096 for faster response
            format: audioEngine.inputNode.outputFormat(forBus: 0)
        ) { buffer, _ in
            onBuffer(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        audioTapInstalled = true
    }

    func stopAudioStream() {
        guard audioTapInstalled else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioTapInstalled = false
    }
}


