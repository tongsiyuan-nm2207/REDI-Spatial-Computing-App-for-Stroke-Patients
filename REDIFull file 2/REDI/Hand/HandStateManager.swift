//
//  HandStateManager.swift
//  REDI
//
//  Created by Interactive 3D Design on 25/10/25.
//
import SwiftUI
import Combine

@MainActor
class HandStateManager: ObservableObject {
    static let shared = HandStateManager()
    
    @Published var leftHandHeight: Float = 0.0
    @Published var leftHandLifted: Bool = false
    
    @Published var rightHandHeight: Float = 0.0
    @Published var rightHandLifted: Bool = false
    
    private init() {}
    
    func updateLeftHand(height: Float, lifted: Bool) {
        leftHandHeight = height
        leftHandLifted = lifted
    }
    
    func updateRightHand(height: Float, lifted: Bool) {
        rightHandHeight = height
        rightHandLifted = lifted
    }
}

