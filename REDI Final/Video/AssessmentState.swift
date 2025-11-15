//
//  AssessmentState.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 31/10/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class AssessmentState {
    var score: Int = 0
    var averageReactionTime: Double = 0
    var isCompleted: Bool = false
    
    func completeAssessment(score: Int, averageReactionTime: Double) {
        self.score = score
        self.averageReactionTime = averageReactionTime
        self.isCompleted = true
    }
    
    func reset() {
        score = 0
        averageReactionTime = 0
        isCompleted = false
    }
}
