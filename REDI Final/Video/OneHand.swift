//
//  OneHand.swift
//  REDI
//
//  Created by Interactive 3D Design on 27/10/25.
//

import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct OneHandView: View {
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var showingResults = false
    @State private var masterTimer: Timer?  // ✅ Master video synchronization timer
    @State private var reactionTimes: [Double] = []
    @State private var videoStartTime: Date?  // ✅ When video started
    @State private var currentQuestionStartTime: Date?  // ✅ When current question started
    @State private var hasAnsweredCurrentQuestion = false  // ✅ Prevent duplicate answers
    @State private var showTransitionGIF = false  // ✅ Show transition GIF between questions
    @State private var showCompletionGIF = false  // ✅ Show completion GIF after final question
    
    // ✅ Callback to stop video playback
    var stopVideoAction: (() -> Void)? = nil
    
    // ✅ Environment to dismiss immersive space and open completion window
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(AssessmentState.self) private var assessmentState
    
    let prompts = [
        "What kind of crossing is infront of you?",
        "What is the current colour of the traffic light?",
        "How many red cars are there?",
        "What is the bus number of this bus?"
    ]
    
    // Time delays for each prompt in seconds
    let promptDelays: [Double] = [34, 33, 32, 30]
    
    // ✅ Calculate cumulative timestamps for when each question should appear
    var questionTimestamps: [Double] {
        var timestamps: [Double] = [0]  // Q1 starts at 0
        for i in 0..<promptDelays.count - 1 {
            timestamps.append(timestamps[i] + promptDelays[i])
        }
        return timestamps  // [0, 34, 64, 97]
    }
    
    // ✅ Calculate current elapsed video time
    var currentVideoTime: Double {
        guard let startTime = videoStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    // Computed property for average reaction time
    var averageReactionTime: Double {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            if showTransitionGIF {
                // Transition GIF - loops until next question
                VStack(spacing: 20) {
                    Text("Good job!")
                        .font(.custom("Nohemi-Black", size: 36))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "5237b5"))
                        .padding(.vertical, 40)
                        .padding(.horizontal, 32)
                        .background(.white)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(Color(hex: "5237b5").opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: 400)
                    
                    GIFPlayerView("completed_question", playOnce: false) {
                        // This won't be called since playOnce is false
                    }
                    .frame(width: 1500, height: 900)
                }
                .transition(.opacity)
                
            } else {
                // Normal question UI
                ZStack {
                    VStack(spacing: 80) {
                        Spacer()
                        
                        // Prompt text with white background
                        Text(prompts[min(clickCount, prompts.count - 1)])
                            .font(.custom("Nohemi-Bold", size: 48))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "5237b5"))
                            .multilineTextAlignment(.center)
                            .frame(width: 900)
                            .padding(.vertical, 40)
                            .padding(.horizontal, 32)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .stroke(Color(hex: "5237b5").opacity(0.1), lineWidth: 1)
                            )
                            .animation(.easeInOut(duration: 0.3), value: clickCount)
                        
                        HandCardView(
                            clickCount: $clickCount,
                            marks: $marks,
                            showingResults: $showingResults,
                            onCardTap: {
                                print("🎯 DEBUG: === Card Tapped ===")
                                print("🎯 DEBUG: Question \(clickCount + 1) answered")
                                print("🎯 DEBUG: Video time: \(String(format: "%.2f", currentVideoTime))s")
                                
                                // ✅ Check if we're still in the valid time window for this question
                                let currentQuestionTimestamp = questionTimestamps[clickCount]
                                let currentQuestionEndTime = currentQuestionTimestamp + promptDelays[clickCount]
                                let videoTime = currentVideoTime
                                
                                // Validate answer is within time window
                                guard videoTime <= currentQuestionEndTime else {
                                    print("⚠️ Answer rejected - time window expired for Question \(clickCount + 1)")
                                    return
                                }
                                
                                // Prevent duplicate answers
                                guard !hasAnsweredCurrentQuestion else {
                                    print("⚠️ Answer rejected - Question \(clickCount + 1) already answered")
                                    return
                                }
                                
                                // Calculate reaction time for this question
                                if let startTime = currentQuestionStartTime {
                                    let reactionTime = Date().timeIntervalSince(startTime)
                                    reactionTimes.append(reactionTime)
                                    print("✅ Reaction time for Question \(clickCount + 1): \(String(format: "%.2f", reactionTime)) seconds")
                                }
                                
                                // Mark as answered (marks already updated in HandCardView)
                                hasAnsweredCurrentQuestion = true
                                
                                print("📊 Current marks: \(marks)")
                                
                                // ✅ If this is Q4, handle completion
                                if clickCount == 3 {
                                    print("🎬 Q4 answered - stopping video and completing assessment")
                                    stopVideoAction?()
                                    
                                    // Save results to AssessmentState
                                    assessmentState.completeAssessment(
                                        score: marks,
                                        averageReactionTime: averageReactionTime
                                    )
                                    print("💾 Results saved - Score: \(marks), Avg RT: \(String(format: "%.2f", averageReactionTime))s")
                                    
                                    // Dismiss immersive space and open completion window
                                    Task {
                                        await dismissImmersiveSpace()
                                        print("🚪 Immersive space dismissed")
                                        
                                        // Small delay to ensure smooth transition
                                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                                        
                                        openWindow(id: "CompletionWindow")
                                        print("🪟 Completion window opened")
                                    }
                                } else {
                                    // Questions 1-3: Show looping transition GIF
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showTransitionGIF = true
                                    }
                                }
                                
                                print("🎯 DEBUG: === End Card Tap Handler ===\n")
                            }
                        )
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showTransitionGIF)
        .onAppear {
            print("🎬 OneHandView appeared - starting video timer")
            startVideoTimer()
        }
        .onDisappear {
            print("🎬 OneHandView disappeared - cleaning up")
            cleanupTimers()
        }
    }
    
    // ✅ Start the master video timer
    private func startVideoTimer() {
        // Record when video started
        videoStartTime = Date()
        currentQuestionStartTime = Date()
        hasAnsweredCurrentQuestion = false
        
        print("⏱️ Video timer started at timestamp 0s")
        print("📍 Question \(clickCount + 1) window: \(questionTimestamps[clickCount])s - \(questionTimestamps[clickCount] + promptDelays[clickCount])s")
        
        // Create a timer that checks every 0.1 seconds
        masterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkVideoProgress()
        }
    }
    
    // ✅ Check video progress and auto-advance questions at timestamps
    private func checkVideoProgress() {
        let videoTime = currentVideoTime
        
        // Check if we've reached the next question's timestamp
        let nextQuestionIndex = clickCount + 1
        
        if nextQuestionIndex < questionTimestamps.count {
            let nextTimestamp = questionTimestamps[nextQuestionIndex]
            
            // Time to move to next question
            if videoTime >= nextTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Time for Question \(nextQuestionIndex + 1)")
                
                // If current question wasn't answered, mark it wrong
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[clickCount]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(clickCount + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                // Hide transition GIF before moving to next question
                if showTransitionGIF {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTransitionGIF = false
                    }
                }
                
                // Move to next question
                moveToNextQuestion()
            }
        } else if clickCount == 3 {
            // We're on the last question (Q4), check if time window expired
            let finalTimestamp = questionTimestamps[3] + promptDelays[3]  // 97 + 30 = 127s
            
            if videoTime >= finalTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Assessment complete (time expired)")
                
                // If last question wasn't answered, mark it wrong
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[clickCount]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(clickCount + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                    
                    // Stop video even if they didn't answer
                    print("🎬 Time expired - stopping video")
                    stopVideoAction?()
                    
                    // Save results and complete assessment
                    assessmentState.completeAssessment(
                        score: marks,
                        averageReactionTime: averageReactionTime
                    )
                    print("💾 Results saved - Score: \(marks), Avg RT: \(String(format: "%.2f", averageReactionTime))s")
                    
                    // Dismiss immersive space and open completion window
                    Task {
                        await dismissImmersiveSpace()
                        print("🚪 Immersive space dismissed")
                        
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        
                        openWindow(id: "CompletionWindow")
                        print("🪟 Completion window opened")
                    }
                }
            }
        }
    }
    
    // ✅ Move to next question
    private func moveToNextQuestion() {
        print("📍 DEBUG: === moveToNextQuestion() called ===")
        print("📍 DEBUG: Moving from Question \(clickCount + 1) to Question \(clickCount + 2)")
        
        // Move to next question
        clickCount += 1
        hasAnsweredCurrentQuestion = false
        currentQuestionStartTime = Date()
        
        if clickCount < prompts.count {
            print("📍 Question \(clickCount + 1) window: \(questionTimestamps[clickCount])s - \(questionTimestamps[clickCount] + promptDelays[clickCount])s")
        }
        
        print("📍 DEBUG: === End moveToNextQuestion() ===\n")
    }
    
    // ✅ Clean up timers
    private func cleanupTimers() {
        masterTimer?.invalidate()
        masterTimer = nil
        print("🧹 Timers cleaned up")
    }
}

#Preview(windowStyle: .volumetric) {
    OneHandView()
        .environment(AssessmentState())
}
