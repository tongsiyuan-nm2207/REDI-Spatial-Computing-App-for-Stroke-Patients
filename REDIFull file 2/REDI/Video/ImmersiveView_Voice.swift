import SwiftUI
import RealityKit
import AVFoundation

struct VoiceImmersiveView: View {
    @State private var rootEntity = Entity()
    @State private var avPlayer: AVPlayer?
    
    // Speech recognition using @Observable
    @State private var speechManager = GameSpeechManager()
    
    // Environment for dismissing immersive space
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AssessmentState.self) private var assessmentState
    
    var body: some View {
        RealityView { content, attachments in
            // Set up the immersive video player - only once
            if avPlayer == nil {
                let player = AVPlayer(url: Bundle.main.url(forResource: "FinalLevel1", withExtension: "aivu")!)
                avPlayer = player
                
                var videoPlayerComponent = VideoPlayerComponent(avPlayer: player)
                videoPlayerComponent.desiredSpatialVideoMode = .spatial
                videoPlayerComponent.desiredImmersiveViewingMode = .full
                videoPlayerComponent.desiredViewingMode = .stereo
                player.play()
                
                let videoEntity = Entity(components: [videoPlayerComponent])
                rootEntity.addChild(videoEntity)
            }
            
            content.add(rootEntity)
            
            // Add the OneVoice UI attachment
            if let uiAttachment = attachments.entity(for: "oneVoiceUI") {
                uiAttachment.position = [0, 0.75, -1.5]
                rootEntity.addChild(uiAttachment)
            }
            
        } update: { content, attachments in
            // Update the UI attachment position when needed
            if let uiAttachment = attachments.entity(for: "oneVoiceUI") {
                uiAttachment.position = [0, 0.75, -1.5]
            }
            
        } attachments: {
            Attachment(id: "oneVoiceUI") {
                // ✅ Use OneVoice which has the timer-based question system
                OneVoiceWithSpeech(speechManager: speechManager)
            }
        }
        .onAppear {
            // Start speech recognition when view appears
            if !speechManager.model.isRecording {
                speechManager.toggleRecording()
            }
        }
        .onDisappear {
            // Stop speech recognition when view disappears
            if speechManager.model.isRecording {
                speechManager.toggleRecording()
            }
        }
    }
}

// ✅ Wrapper to pass speech manager into OneVoice
struct OneVoiceWithSpeech: View {
    @State private var promptIndex = 0
    @State private var tapCount = 0
    @State private var showingResults = false
    @State private var masterTimer: Timer?
    @State private var reactionTimes: [Double] = []
    @State private var videoStartTime: Date?
    @State private var currentQuestionStartTime: Date?
    @State private var hasAnsweredCurrentQuestion = false
    @State private var lastCheckedText = ""
    @State private var showTransitionGIF = false
    @State private var showCompletionGIF = false
    
    let speechManager: GameSpeechManager
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AssessmentState.self) private var assessmentState
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "How many red cars are there?",
        "What is the bus number of this bus?"
    ]
    
    // Expected answers for each prompt
    let expectedAnswers = [
        ["zebra", "zebra crossing"],
        ["red", "red light"],
        ["left", "left side"],
        ["970", "nine seven zero", "nine seventy", "nine hundred seventy"]
    ]
    
    let promptDelays: [Double] = [34, 33, 32, 30]
    
    var questionTimestamps: [Double] {
        var timestamps: [Double] = [0]
        for i in 0..<promptDelays.count - 1 {
            timestamps.append(timestamps[i] + promptDelays[i])
        }
        return timestamps  // [0, 34, 64, 97]
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
            
            if !showingResults {
                if showCompletionGIF {
                    // Completion GIF - plays once after final question
                    GIFPlayerView("completed_test", playOnce: true) {
                        // Called when completion GIF finishes playing
                        handleCompletionGIFComplete()
                    }
                    .frame(width: 1300, height: 700)
                    .transition(.opacity)
                    
                } else if showTransitionGIF {
                    // Transition GIF - loops until next question
                    VStack(spacing: 20) {
                        Text("Good job!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Rectangle()
                            .fill(.white.opacity(0.3))
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
                    VStack(spacing: 40) {
                        // Prompt text with glass background
                        Text(prompts[promptIndex])
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 900)
                            .padding(.vertical, 40)
                            .padding(.horizontal, 32)
                            .glassBackgroundEffect()
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .id(promptIndex)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: promptIndex)
                        
                        // Voice visualization card (non-interactive)
                        VoiceVisualizationCard(isRecording: speechManager.model.isRecording)
                            .glassBackgroundEffect()
                        
                        // Transcription display
                        VStack(spacing: 16) {
                            if !speechManager.model.displayText.isEmpty {
                                Text(speechManager.model.displayText)
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.white.opacity(0.1))
                                    )
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: speechManager.model.displayText)
                        
                        // Error message display
                        if let errorMessage = speechManager.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 16))
                                .foregroundStyle(.red.opacity(0.8))
                                .padding()
                        }
                    }
                    .frame(width: 600)
                    .padding(40)
                    .transition(.opacity)
                }
            } else {
                AssessmentResultsView(marks: tapCount, averageReactionTime: averageReactionTime)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingResults)
        .animation(.easeInOut(duration: 0.3), value: showTransitionGIF)
        .animation(.easeInOut(duration: 0.3), value: showCompletionGIF)
        .onAppear {
            print("🎬 OneVoiceWithSpeech appeared - starting video timer")
            startVideoTimer()
        }
        .onDisappear {
            print("🎬 OneVoiceWithSpeech disappeared - cleaning up")
            cleanupTimers()
        }
        .onChange(of: speechManager.model.displayText) { oldValue, newValue in
            checkAnswer(newValue)
        }
        .onChange(of: showingResults) { oldValue, newValue in
            if newValue {
                // ✅ Save results but don't dismiss - let user press Finish button
                assessmentState.completeAssessment(score: tapCount, averageReactionTime: averageReactionTime)
            }
        }
    }
    
    private func startVideoTimer() {
        videoStartTime = Date()
        currentQuestionStartTime = Date()
        hasAnsweredCurrentQuestion = false
        lastCheckedText = ""
        
        print("⏱️ Video timer started at timestamp 0s")
        print("📍 Question \(promptIndex + 1) window: \(questionTimestamps[promptIndex])s - \(questionTimestamps[promptIndex] + promptDelays[promptIndex])s")
        
        masterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkVideoProgress()
        }
    }
    
    private func checkVideoProgress() {
        let videoTime = currentVideoTime
        let nextQuestionIndex = promptIndex + 1
        
        if nextQuestionIndex < questionTimestamps.count {
            let nextTimestamp = questionTimestamps[nextQuestionIndex]
            
            if videoTime >= nextTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Time for Question \(nextQuestionIndex + 1)")
                
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[promptIndex]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(promptIndex + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                // Hide transition GIF before moving to next question
                if showTransitionGIF {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTransitionGIF = false
                    }
                }
                
                moveToNextQuestion()
            }
        } else if promptIndex == 3 {
            // We're on the last question (Q4), check if time window expired
            let finalTimestamp = questionTimestamps[3] + promptDelays[3]  // 97 + 30 = 127s
            
            if videoTime >= finalTimestamp {
                print("🕐 Video reached \(String(format: "%.1f", videoTime))s - Assessment complete")
                
                if !hasAnsweredCurrentQuestion {
                    let timeSpent = promptDelays[promptIndex]
                    reactionTimes.append(timeSpent)
                    print("❌ Question \(promptIndex + 1) not answered - recorded \(String(format: "%.2f", timeSpent))s as reaction time")
                }
                
                finishAssessment()
            }
        }
    }
    
    private func checkAnswer(_ transcribedText: String) {
        guard !hasAnsweredCurrentQuestion else { return }
        guard transcribedText.count >= 3 else { return }
        guard transcribedText != lastCheckedText else { return }
        
        // ✅ Validate answer is within time window
        let currentQuestionTimestamp = questionTimestamps[promptIndex]
        let currentQuestionEndTime = currentQuestionTimestamp + promptDelays[promptIndex]
        let videoTime = currentVideoTime
        
        guard videoTime <= currentQuestionEndTime else {
            print("⚠️ Answer rejected - time window expired for Question \(promptIndex + 1)")
            return
        }
        
        lastCheckedText = transcribedText
        
        let lowercasedText = transcribedText.lowercased()
        let currentExpectedAnswers = expectedAnswers[promptIndex]
        
        let isCorrect = currentExpectedAnswers.contains { answer in
            lowercasedText.contains(answer)
        }
        
        if isCorrect {
            if let startTime = currentQuestionStartTime {
                let reactionTime = Date().timeIntervalSince(startTime)
                reactionTimes.append(reactionTime)
                print("✅ Correct! Reaction time: \(String(format: "%.2f", reactionTime)) seconds")
            }
            
            hasAnsweredCurrentQuestion = true
            tapCount += 1
            
            // ✅ Clear transcript for next question
            speechManager.clearTranscript()
            lastCheckedText = ""
            
            print("📊 Answers given: \(tapCount)/4")
            
            // Show appropriate GIF
            if promptIndex < 3 {
                // Questions 1-3: Show looping transition GIF
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTransitionGIF = true
                }
            } else {
                // Question 4: Show completion GIF (plays once)
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCompletionGIF = true
                }
            }
            
            // ✅ DON'T advance - let master timer handle it (for Q1-3)
            // For Q4, completion GIF will handle transition to results
        }
    }
    
    private func moveToNextQuestion() {
        print("📍 DEBUG: === moveToNextQuestion() called ===")
        print("📍 DEBUG: Moving from Question \(promptIndex + 1) to Question \(promptIndex + 2)")
        
        promptIndex += 1
        hasAnsweredCurrentQuestion = false
        currentQuestionStartTime = Date()
        lastCheckedText = ""
        
        // Clear transcript for new question
        speechManager.clearTranscript()
        
        if promptIndex < prompts.count {
            print("📍 Question \(promptIndex + 1) window: \(questionTimestamps[promptIndex])s - \(questionTimestamps[promptIndex] + promptDelays[promptIndex])s")
        }
        
        print("📍 DEBUG: === End moveToNextQuestion() ===\n")
    }
    
    private func finishAssessment() {
        print("🏁 DEBUG: === finishAssessment() called ===")
        print("📊 Final Answers: \(tapCount)/4")
        print("📊 All reaction times: \(reactionTimes.map { String(format: "%.2f", $0) })")
        print("⏱️ Average reaction time: \(String(format: "%.2f", averageReactionTime)) seconds")
        
        cleanupTimers()
        
        // If completion GIF is showing, it will handle the transition to results
        // Otherwise, show results immediately
        if !showCompletionGIF {
            showingResults = true
        }
        
        print("🏁 DEBUG: === End finishAssessment() ===\n")
    }
    
    private func handleCompletionGIFComplete() {
        // Called when the completion GIF finishes playing once
        print("🎉 Completion GIF finished - holding for 3 seconds")
        
        // ✅ Hold the completed GIF on screen for 3 seconds, then show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("📊 Now showing results")
            showCompletionGIF = false
            showingResults = true
        }
    }
    
    private func cleanupTimers() {
        masterTimer?.invalidate()
        masterTimer = nil
        print("🧹 Timers cleaned up")
    }
}

#Preview(immersionStyle: .full) {
    VoiceImmersiveView()
        .environment(AppModel())
        .environment(AssessmentState())
}
