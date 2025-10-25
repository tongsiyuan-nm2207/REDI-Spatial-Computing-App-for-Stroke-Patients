//
//  OneVoice.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//
import SwiftUI

struct OneVoice: View {
    @State private var promptIndex = 0
    @State private var tapCount = 0
    @State private var showingResults = false
    @State private var timer: Timer?
    @State private var reactionTimes: [Double] = []
    @State private var promptStartTime: Date?
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are the cars parked?",
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
                    VStack(spacing:80) {
                        // Prompt text with clean transition
                        Text(prompts[promptIndex])
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .id(promptIndex) // Force view replacement for clean transition
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: promptIndex)
                        
                        VoiceCardView(onTap: {
                            // Calculate reaction time
                            if let startTime = promptStartTime {
                                let reactionTime = Date().timeIntervalSince(startTime)
                                reactionTimes.append(reactionTime)
                                print("✅ Reaction time for prompt \(promptIndex): \(String(format: "%.2f", reactionTime)) seconds")
                            }
                            
                            // Cancel existing timer when user taps
                            timer?.invalidate()
                            
                            tapCount += 1
                            
                            // Check if this is the 4th tap
                            if tapCount >= 4 {
                                print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
                                print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
                                showingResults = true
                            } else {
                                // Cycle through prompts
                                promptIndex = (promptIndex + 1) % prompts.count
                                // Start new timer for next prompt
                                startTimer()
                            }
                        })
                        
                        Spacer()
                            .frame(height: 0)
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
                AssessmentResultsView(marks: 0, averageReactionTime: averageReactionTime)
                    .transition(.opacity)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingResults)
    }
    
    private func startTimer() {
        // Set start time for this prompt
        promptStartTime = Date()
        print("⏱️ Timer started for prompt \(promptIndex): \"\(prompts[promptIndex])\"")
        
        // Get the delay for the current prompt
        let delay = promptDelays[promptIndex]
        
        // Create timer with the appropriate delay
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            // User didn't tap - record full delay time as reaction time
            reactionTimes.append(delay)
            print("⏰ No tap - recorded full delay of \(String(format: "%.2f", delay)) seconds for prompt \(promptIndex)")
            
            // Check if we're on the last prompt
            if promptIndex == 3 {
                print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
                print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
                // Navigate to results after delay on 4th prompt
                showingResults = true
            } else {
                // Move to next prompt
                promptIndex += 1
                tapCount += 1
                // Start timer for next prompt
                startTimer()
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    OneVoice()
}
