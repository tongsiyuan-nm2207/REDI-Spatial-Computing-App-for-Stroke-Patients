//
//  TranscriptionModel.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 27/10/25.
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

