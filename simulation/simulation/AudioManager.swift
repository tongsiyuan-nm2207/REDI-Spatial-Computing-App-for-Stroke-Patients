//
//  AudioManager.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//

import Foundation
import AVFoundation

class AudioManager {

    // 1.
    private let audioEngine = AVAudioEngine()
    private var audioTapInstalled = false

    // 2.
    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    // 3.
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // 4. Updated to handle format properly
    func startAudioStream(onBuffer: @escaping (AVAudioPCMBuffer) -> Void) throws {
        guard !audioTapInstalled else { return }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Create a format that's compatible with Speech framework
        // Speech typically works best with 16kHz, mono, Float32
        let desiredFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        )
        
        guard let targetFormat = desiredFormat else {
            throw NSError(domain: "AudioManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create target format"])
        }
        
        // Use a reasonable buffer size that works with the sample rate
        let bufferSize: AVAudioFrameCount = 1024
        
        inputNode.installTap(
            onBus: 0,
            bufferSize: bufferSize,
            format: inputFormat // Use the input format for the tap
        ) { buffer, _ in
            onBuffer(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        audioTapInstalled = true
    }

    // 5.
    func stopAudioStream() {
        guard audioTapInstalled else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioTapInstalled = false
    }
}

