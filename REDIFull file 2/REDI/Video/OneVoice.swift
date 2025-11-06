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
    @State private var masterTimer: Timer?  // ✅ Master video synchronization timer
    @State private var reactionTimes: [Double] = []
    @State private var videoStartTime: Date?  // ✅ When video started
    @State private var currentQuestionStartTime: Date?  // ✅ When current question started
    @State private var hasAnsweredCurrentQuestion = false  // ✅ Prevent duplicate answers
    
    let prompts = [
        "What's in front of you?",
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
                            print("🎯 DEBUG: === Voice Answer Detected ===")
                            print("🎯 DEBUG: Question \(promptIndex + 1) answered")
                            print("🎯 DEBUG: Video time: \(String(format: "%.2f", currentVideoTime))s")
                            
                            // ✅ Check if we're still in the valid time window for this question
                            let currentQuestionTimestamp = questionTimestamps[promptIndex]
                            let currentQuestionEndTime = currentQuestionTimestamp + promptDelays[promptIndex]
                            let videoTime = currentVideoTime
                            
                            // Validate answer is within time window
                            guard videoTime <= currentQuestionEndTime else {
                                print("⚠️ Answer rejected - time window expired for Question \(promptIndex + 1)")
                                return
                            }
                            
                            // Prevent duplicate answers
                            guard !hasAnsweredCurrentQuestion else {
                                print("⚠️ Answer rejected - Question \(promptIndex + 1) already answered")
                                return
                            }
                            
                            // Calculate reaction time for this question
                            if let startTime = currentQuestionStartTime {
                                let reactionTime = Date().timeIntervalSince(startTime)
                                reactionTimes.append(reactionTime)
                                print("✅ Reaction time for Question \(promptIndex + 1): \(String(format: "%.2f", reactionTime)) seconds")
                            }
                            
                            // Mark as answered
                            hasAnsweredCurrentQuestion = true
                            tapCount += 1
                            
                            print("📊 Answers given: \(tapCount)/4")
                            print("🎯 DEBUG: === End Voice Answer Handler ===\n")
                            
                            // ✅ FIXED: Don't manually advance - let the master timer handle it at the video timestamp
                            // The question will automatically advance when video reaches next timestamp
                        })
                        
                        Spacer()
                            .frame(height: 0)
                    }
                }
                .transition(.opacity)
                .onAppear {
                    print("🎬 OneVoice appeared - starting video timer")
                    startVideoTimer()
                }
                .onDisappear {
                    print("🎬 OneVoice disappeared - cleaning up")
                    cleanupTimers()
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
    
    // ✅ Start the master video timer
    private func startVideoTimer() {
        // Record when video started
        videoStartTime = Date()
        currentQuestionStartTime = Date()
        hasAnsweredCurrentQuestion = false
        
        print("⏱️ Video timer started at timestamp 0s")
        print("📍 Question \(promptIndex + 1) window: \(questionTimestamps[promptIndex])s - \(questionTimestamps[promptIndex] + promptDelays[promptIndex])s")
        
        // Create a timer that checks every 0.1 seconds
        masterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkVideoProgress()
        }
    }
    
    // ✅ Check video progress and auto-advance questions at timestamps
    private func checkVideoProgress() {
        let videoTime = currentVideoTime
        
        // Check if we've reached the next question's timestamp
        let nextQuestionIndex = promptIndex + 1
        
        if nextQuestionIndex < questionTimestamps.count {
            let nextTimestamp = questionTimestamps[nextQuestionIndex]
            
            // Time to move to next question
            if videoTime >= nextTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Time for Question \(nextQuestionIndex + 1)")
                
                // If current question wasn't answered, mark it wrong
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[promptIndex]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(promptIndex + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                // Move to next question
                moveToNextQuestion()
            }
        } else if promptIndex == 3 {
            // We're on the last question (Q4), check if time window expired
            let finalTimestamp = questionTimestamps[3] + promptDelays[3]  // 97 + 30 = 127s
            
            if videoTime >= finalTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Assessment complete")
                
                // If last question wasn't answered, mark it wrong
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[promptIndex]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(promptIndex + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                // Show results
                finishAssessment()
            }
        }
    }
    
    // ✅ Move to next question (ONLY called by master timer)
    private func moveToNextQuestion() {
        print("📍 DEBUG: === moveToNextQuestion() called ===")
        print("📍 DEBUG: Moving from Question \(promptIndex + 1) to Question \(promptIndex + 2)")
        
        // Move to next question
        promptIndex += 1
        hasAnsweredCurrentQuestion = false
        currentQuestionStartTime = Date()
        
        if promptIndex < prompts.count {
            print("📍 Question \(promptIndex + 1) window: \(questionTimestamps[promptIndex])s - \(questionTimestamps[promptIndex] + promptDelays[promptIndex])s")
        }
        
        print("📍 DEBUG: === End moveToNextQuestion() ===\n")
    }
    
    // ✅ Finish assessment and show results
    private func finishAssessment() {
        print("🏁 DEBUG: === finishAssessment() called ===")
        print("📊 Final Answers: \(tapCount)/4")
        print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
        print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
        
        // Stop master timer
        cleanupTimers()
        
        // Show results
        showingResults = true
        
        print("🏁 DEBUG: === End finishAssessment() ===\n")
    }
    
    // ✅ Clean up timers
    private func cleanupTimers() {
        masterTimer?.invalidate()
        masterTimer = nil
        print("🧹 Timers cleaned up")
    }
}

#Preview(windowStyle: .volumetric) {
    OneVoice()
}
