//
//  AssessmentCompletionWindow.swift
//  REDI
//
//  Created for handling completion GIF and results outside immersive space
//

import SwiftUI

struct AssessmentCompletionWindow: View {
    @Environment(AssessmentState.self) private var assessmentState
    @State private var showingGIF = true
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
            
            if showingGIF {
                // Completion GIF - plays once
                GIFPlayerView("completed_test", playOnce: true) {
                    // When GIF finishes, show results
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGIF = false
                        showingResults = true
                    }
                }
                .frame(width: 1300, height: 700)
                .transition(.opacity)
                
            } else if showingResults {
                // Results view
                AssessmentResultsView(
                    marks: assessmentState.score,
                    averageReactionTime: assessmentState.averageReactionTime
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AssessmentCompletionWindow()
        .environment(AssessmentState())
}
