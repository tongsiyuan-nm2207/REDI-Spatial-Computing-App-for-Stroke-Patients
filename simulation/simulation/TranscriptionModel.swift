//
//  TranscriptionModel.swift
//  voice_ios
//
//  Created by Interactive 3D Design on 27/9/25.
//

import Foundation

struct TranscriptionModel {
    var finalizedText: String = ""
    var currentText: String = ""
    var isRecording: Bool = false
    
    var displayText: String {
        return finalizedText + currentText
    }
}

