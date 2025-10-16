//
//  BufferConverter.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//

import Foundation
import Speech
import AVFoundation

class BufferConverter {

    // 1.
    enum Error: Swift.Error {
        case failedToCreateConverter
        case failedToCreateConversionBuffer
        case conversionFailed(NSError?)
        case unsupportedFormat
    }

    // 2.
    private var converter: AVAudioConverter?
    private var lastInputFormat: AVAudioFormat?

    // 3. Enhanced conversion with better format handling
    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format
        
        // If formats are already the same, return the original buffer
        guard !inputFormat.isEqual(format) else {
            return buffer
        }
        
        // Check if we need to create a new converter
        if converter == nil ||
           lastInputFormat == nil ||
           !lastInputFormat!.isEqual(inputFormat) ||
           !converter!.outputFormat.isEqual(format) {
            
            converter = AVAudioConverter(from: inputFormat, to: format)
            lastInputFormat = inputFormat
            converter?.primeMethod = .none
        }
        
        guard let converter = converter else {
            throw Error.failedToCreateConverter
        }
        
        // Calculate the output buffer size more accurately
        let sampleRateRatio = converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let channelRatio = Double(converter.outputFormat.channelCount) / Double(converter.inputFormat.channelCount)
        let scaledFrameLength = Double(buffer.frameLength) * sampleRateRatio * channelRatio
        let frameCapacity = AVAudioFrameCount(ceil(scaledFrameLength))
        
        guard let conversionBuffer = AVAudioPCMBuffer(
            pcmFormat: converter.outputFormat,
            frameCapacity: frameCapacity
        ) else {
            throw Error.failedToCreateConversionBuffer
        }
        
        var nsError: NSError?
        var inputConsumed = false
        
        let status = converter.convert(to: conversionBuffer, error: &nsError) { packetCount, inputStatusPointer in
            guard !inputConsumed else {
                inputStatusPointer.pointee = .noDataNow
                return nil
            }
            
            inputConsumed = true
            inputStatusPointer.pointee = .haveData
            return buffer
        }
        
        switch status {
        case .error:
            throw Error.conversionFailed(nsError)
        case .haveData, .endOfStream:
            return conversionBuffer
        case .inputRanDry:
            // This is normal for some conversions
            return conversionBuffer
        @unknown default:
            throw Error.conversionFailed(nsError)
        }
    }
    
    // Helper function to create Speech-compatible format
    static func createSpeechCompatibleFormat() -> AVAudioFormat? {
        return AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        )
    }
}
