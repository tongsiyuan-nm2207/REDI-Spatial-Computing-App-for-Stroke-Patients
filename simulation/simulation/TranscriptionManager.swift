//
//  TranscriptionManager.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//

import Foundation
import Speech

class TranscriptionManager {

    // 1.
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var recognizerTask: Task<(), Error>?
    private var analyzerFormat: AVAudioFormat?
    private var converter = BufferConverter()

    // 2.
    func requestSpeechPermission() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return status == .authorized
    }

    // 3. Enhanced startup with better format handling
    func startTranscription(onResult: @escaping (String, Bool) -> Void) async throws {
        // Clean up any existing resources
        await stopTranscription()
        
        transcriber = SpeechTranscriber(
            locale: Locale.current,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: []
        )
        analyzer = SpeechAnalyzer(modules: [transcriber!])
        
        // Get the best available format, with fallback
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber!])
        
        // If no format is available, create a fallback
        if analyzerFormat == nil {
            analyzerFormat = BufferConverter.createSpeechCompatibleFormat()
        }
        
        guard analyzerFormat != nil else {
            throw NSError(domain: "TranscriptionManager", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "Could not determine compatible audio format for speech recognition"
            ])
        }
        
        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputBuilder = inputBuilder
        
        // Start the recognition task
        recognizerTask = Task { [weak self] in
            guard let transcriber = self?.transcriber else { return }
            
            do {
                for try await result in transcriber.results {
                    let text = String(result.text.characters)
                    await MainActor.run {
                        onResult(text, result.isFinal)
                    }
                }
            } catch {
                print("Speech recognition error: \(error)")
            }
        }
        
        // Start the analyzer
        do {
            try await analyzer?.start(inputSequence: inputSequence)
        } catch {
            await stopTranscription()
            throw error
        }
    }

    // 4. Enhanced buffer processing with error handling
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) throws {
        guard let inputBuilder = inputBuilder,
              let analyzerFormat = analyzerFormat else {
            return
        }
        
        do {
            let converted = try converter.convertBuffer(buffer, to: analyzerFormat)
            inputBuilder.yield(AnalyzerInput(buffer: converted))
        } catch {
            print("Buffer conversion error: \(error)")
            // Don't throw here to avoid breaking the audio stream
            // Just skip this buffer
        }
    }

    // 5. Enhanced cleanup
    func stopTranscription() async {
        inputBuilder?.finish()
        inputBuilder = nil
        
        if let analyzer = analyzer {
            do {
                try await analyzer.finalizeAndFinishThroughEndOfInput()
            } catch {
                print("Error finalizing analyzer: \(error)")
            }
        }
        
        recognizerTask?.cancel()
        recognizerTask = nil
        analyzer = nil
        transcriber = nil
        analyzerFormat = nil
    }
}
