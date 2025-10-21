//
//  OneHand.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI

struct OneHandView: View {
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var showingResults = false
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are cars parked?",
        "What is the bus number of this bus?"
    ]
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !showingResults {
                ZStack {
                    // Marks View in top-right corner
                    VStack {
                        HStack {
                            Spacer()
                            MarksView(marks: $marks)
                                .padding(.top, 40)
                                .padding(.trailing, 40)
                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 80) {
                        Spacer()
                        
                        // Prompt text
                        Text(prompts[min(clickCount, prompts.count - 1)])
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.3), value: clickCount)
                        
                        HandCardView(clickCount: $clickCount, marks: $marks, showingResults: $showingResults)
                        
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .transition(.opacity)
            } else {
                AssessmentResultsView(marks: marks)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingResults)
    }
}

#Preview(windowStyle: .volumetric) {
    OneHandView()
}
