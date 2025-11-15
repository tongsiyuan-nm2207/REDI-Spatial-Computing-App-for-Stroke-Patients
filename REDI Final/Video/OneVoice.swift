//
//  OneVoice.swift
//  REDI
//
//  Created by Interactive 3D Design on 1/11/25.
//

import SwiftUI

struct OneVoiceView: View {
    var speechManager: GameSpeechManager
    
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var masterTimer: Timer?
    @State private var reactionTimes: [Double] = []
    @State private var videoStartTime: Date?
    @State private var currentQuestionStartTime: Date?
    @State private var hasAnsweredCurrentQuestion = false
    @State private var showTransitionGIF = false
    
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
    
    let promptDelays: [Double] = [34, 33, 32, 30]
    
    // ✅ MULTIPLE ACCEPTABLE ANSWERS - Each question has an array of acceptable variations
    // Structure: [[Q1 answers], [Q2 answers], [Q3 answers], [Q4 answers]]
    let correctAnswers: [[String]] = [
        // Question 1: "What kind of crossing is of you?"
        [
            "zebra",
            "zebra crossing",
            "zee-bra",           // American pronunciation
            "zeb-ra",            // British pronunciation
            "striped crossing",
            "pedestrian crossing",
            "crossing"
        ],
        
        // Question 2: "What is the current colour of the traffic light?"
        [
            "red",
            "red light",
            "stop",
            "stop light",
            "red traffic light"
        ],
        
        // Question 3: "How many red cars are there?"
        [
            "3",
            "three",
            "tree",              // Common mispronunciation
            "free",              // Another common mispronunciation
            "three cars",
            "3 cars"
        ],
        
        // Question 4: "What is the bus number of this bus?"
        [
            "970",
            "nine seven zero",
            "nine seventy",
            "nine hundred seventy",
            "nine seven oh",
            "nine hundred and seventy"
        ]
    ]
    
    var questionTimestamps: [Double] {
        var timestamps: [Double] = [0]
        for i in 0..<promptDelays.count - 1 {
            timestamps.append(timestamps[i] + promptDelays[i])
        }
        return timestamps
    }
    
    var currentVideoTime: Double {
        guard let startTime = videoStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var averageReactionTime: Double {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            if showTransitionGIF {
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
                VStack(spacing: 80) {
                    Spacer()
                    
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
                    
                    VoiceVisualizationCard(isRecording: speechManager.model.isRecording)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showTransitionGIF)
        .onAppear {
            print("🎬 OneVoiceView appeared - starting video timer")
            startVideoTimer()
        }
        .onDisappear {
            print("🎬 OneVoiceView disappeared - cleaning up")
            cleanupTimers()
        }
        .onChange(of: speechManager.model.displayText) { oldValue, newValue in
            handleTranscriptChange(newValue)
        }
    }
    
    private func handleTranscriptChange(_ transcript: String) {
        let transcriptLower = transcript.lowercased()
        
        guard !hasAnsweredCurrentQuestion else {
            print("⚠️ Already answered Question \(clickCount + 1)")
            return
        }
        
        let currentQuestionTimestamp = questionTimestamps[clickCount]
        let currentQuestionEndTime = currentQuestionTimestamp + promptDelays[clickCount]
        let videoTime = currentVideoTime
        
        guard videoTime <= currentQuestionEndTime else {
            print("⚠️ Answer rejected - time window expired for Question \(clickCount + 1)")
            return
        }
        
        // ✅ Get array of acceptable answers for current question
        let acceptableAnswers = correctAnswers[clickCount]
        
        // ✅ Check if transcript contains ANY of the acceptable answers
        var matchedAnswer: String? = nil
        for answer in acceptableAnswers {
            if transcriptLower.contains(answer.lowercased()) {
                matchedAnswer = answer
                break
            }
        }
        
        // ✅ If we found a match, process the correct answer
        if let detectedAnswer = matchedAnswer {
            print("✅ Correct answer detected: '\(detectedAnswer)' from transcript: '\(transcript)'")
            
            if let startTime = currentQuestionStartTime {
                let reactionTime = Date().timeIntervalSince(startTime)
                reactionTimes.append(reactionTime)
                print("✅ Reaction time for Question \(clickCount + 1): \(String(format: "%.2f", reactionTime)) seconds")
            }
            
            marks += 1
            hasAnsweredCurrentQuestion = true
            
            print("📊 Current marks: \(marks)")
            
            if clickCount == 3 {
                print("🎬 Q4 answered - stopping video and completing assessment")
                stopVideoAction?()
                
                assessmentState.completeAssessment(
                    score: marks,
                    averageReactionTime: averageReactionTime
                )
                print("💾 Results saved - Score: \(marks), Avg RT: \(String(format: "%.2f", averageReactionTime))s")
                
                Task {
                    await dismissImmersiveSpace()
                    print("🚪 Immersive space dismissed")
                    
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    
                    openWindow(id: "CompletionWindow")
                    print("🪟 Completion window opened")
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTransitionGIF = true
                }
            }
            
            speechManager.clearTranscript()
        }
    }
    
    private func startVideoTimer() {
        videoStartTime = Date()
        currentQuestionStartTime = Date()
        hasAnsweredCurrentQuestion = false
        
        print("⏱️ Video timer started at timestamp 0s")
        print("📍 Question \(clickCount + 1) window: \(questionTimestamps[clickCount])s - \(questionTimestamps[clickCount] + promptDelays[clickCount])s")
        
        masterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkVideoProgress()
        }
    }
    
    private func checkVideoProgress() {
        let videoTime = currentVideoTime
        let nextQuestionIndex = clickCount + 1
        
        if nextQuestionIndex < questionTimestamps.count {
            let nextTimestamp = questionTimestamps[nextQuestionIndex]
            
            if videoTime >= nextTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Time for Question \(nextQuestionIndex + 1)")
                
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[clickCount]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(clickCount + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                if showTransitionGIF {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTransitionGIF = false
                    }
                }
                
                moveToNextQuestion()
            }
        } else if clickCount == 3 {
            let finalTimestamp = questionTimestamps[3] + promptDelays[3]
            
            if videoTime >= finalTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Assessment complete (time expired)")
                
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[clickCount]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(clickCount + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                    
                    stopVideoAction?()
                    
                    assessmentState.completeAssessment(
                        score: marks,
                        averageReactionTime: averageReactionTime
                    )
                    print("💾 Results saved - Score: \(marks), Avg RT: \(String(format: "%.2f", averageReactionTime))s")
                    
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
    
    private func moveToNextQuestion() {
        print("📍 DEBUG: === moveToNextQuestion() called ===")
        print("📍 DEBUG: Moving from Question \(clickCount + 1) to Question \(clickCount + 2)")
        
        clickCount += 1
        hasAnsweredCurrentQuestion = false
        currentQuestionStartTime = Date()
        
        if clickCount < prompts.count {
            print("📍 Question \(clickCount + 1) window: \(questionTimestamps[clickCount])s - \(questionTimestamps[clickCount] + promptDelays[clickCount])s")
        }
        
        print("📍 DEBUG: === End moveToNextQuestion() ===\n")
    }
    
    private func cleanupTimers() {
        masterTimer?.invalidate()
        masterTimer = nil
        print("🧹 Timers cleaned up")
    }
}

#Preview(windowStyle: .volumetric) {
    OneVoiceView(speechManager: GameSpeechManager())
        .environment(AssessmentState())
}
