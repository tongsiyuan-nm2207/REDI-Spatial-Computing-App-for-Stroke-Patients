//
//  OneHand.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct OneHandView: View {
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var showingResults = false
    @State private var timer: Timer?
    @State private var reactionTimes: [Double] = []
    @State private var promptStartTime: Date?
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are cars parked?",
        "What is the bus number of this bus?"
    ]
    
    // Time delays for each prompt in seconds
    let promptDelays: [Double] = [31, 32, 31, 30]
    
    // Computed property for average reaction time
    var averageReactionTime: Double {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
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
                        
                        HandCardView(
                            clickCount: $clickCount,
                            marks: $marks,
                            showingResults: $showingResults,
                            onCardTap: {
                                // Calculate reaction time
                                if let startTime = promptStartTime {
                                    let reactionTime = Date().timeIntervalSince(startTime)
                                    reactionTimes.append(reactionTime)
                                    print("✅ Reaction time for prompt \(clickCount - 1): \(String(format: "%.2f", reactionTime)) seconds")
                                }
                                
                                // Check if completed all prompts
                                if showingResults {
                                    print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
                                    print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
                                }
                                
                                // Cancel and restart timer when user taps a card
                                timer?.invalidate()
                                if !showingResults {
                                    startTimer()
                                }
                            }
                        )
                        
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .transition(.opacity)
                .onAppear {
                    // Start timer when view appears
                    startTimer()
                }
                .onDisappear {
                    // Clean up timer when view disappears
                    timer?.invalidate()
                }
            } else {
                AssessmentResultsView(marks: marks, averageReactionTime: averageReactionTime)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingResults)
    }
    
    private func startTimer() {
        // Don't start timer if already on last prompt and about to show results
        guard clickCount < prompts.count else { return }
        
        // Set start time for this prompt
        promptStartTime = Date()
        print("⏱️ Timer started for prompt \(clickCount): \"\(prompts[clickCount])\"")
        
        // Get the delay for the current prompt
        let delay = promptDelays[clickCount]
        
        // Create timer with the appropriate delay
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            // User didn't tap - record full delay time as reaction time
            reactionTimes.append(delay)
            print("⏰ No tap - recorded full delay of \(String(format: "%.2f", delay)) seconds for prompt \(clickCount)")
            
            // Check if we're on the last prompt
            if clickCount >= 3 {
                print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
                print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
                // Navigate to results after delay on 4th prompt
                showingResults = true
            } else {
                // Move to next prompt
                clickCount += 1
                // Start timer for next prompt
                startTimer()
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    OneHandView()
}
