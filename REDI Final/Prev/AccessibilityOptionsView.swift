//
//  AccessibilityOptionsView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

import SwiftUI

enum AccessibilityMode {
    case voiceActivated
    case armDetection
}

struct AccessibilityOptionsView: View {
    @State private var isShowingVideo = false
    @State private var isShowingAssessmentLevelView = false
    @State private var selectedMode: AccessibilityMode = .voiceActivated
    @State private var selectedVideoName: String = ""
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isShowingVideo && !isShowingAssessmentLevelView {
                VStack(spacing: 50) {
                    // Title - Using Nohemi font to match system
                    Text("Please select an accessibility option")
                        .font(.custom("Nohemi-Medium", size: 32))
                        .foregroundStyle(Color(hex: "fff16c"))
                        .foregroundStyle(.white)
                    
                    // Option Cards
                    HStack(spacing: 50) {
                        // Voice Activated Card
                        AccessibilityOptionCard(
                            icon: "1",
                            title: "Voice activated",
                            description: "Speak to answer during the assessment",
                            onSelect: {
                                selectedMode = .voiceActivated
                                selectedVideoName = "voice_video"
                                isShowingVideo = true
                            }
                        )
                        .keyboardShortcut("1", modifiers: .command)  // ⌘+1 for Voice
                        
                        // Arm Detection Card
                        AccessibilityOptionCard(
                            icon: "2",
                            title: "Arm detection",
                            description: "Raise your arm to select answers during the assessment",
                            onSelect: {
                                selectedMode = .armDetection
                                selectedVideoName = "hand_video"
                                isShowingVideo = true
                            }
                        )
                        .keyboardShortcut("2", modifiers: .command)  // ⌘+2 for Arm Detection
                    }
                }
                .transition(.opacity)
            } else if isShowingVideo && !isShowingAssessmentLevelView {
                // Show video player
                VideoPlayerView(videoName: selectedVideoName) {
                    // When video completes, show assessment level view
                    isShowingVideo = false
                    isShowingAssessmentLevelView = true
                }
                .transition(.opacity)
            } else {
                // Show assessment level view after video
                AssessmentLevelView(accessibilityMode: selectedMode)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowingVideo)
        .animation(.easeInOut(duration: 0.3), value: isShowingAssessmentLevelView)
    }
}

struct AccessibilityOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let onSelect: () -> Void
    
    var body: some View {
        // The entire card is a button so keyboard shortcut applies to whole card
        Button(action: onSelect) {
            VStack(spacing: 24) {
                // Icon
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(.top, 0)
                    .padding(.bottom,-10)
                
                // Text Content
                VStack(spacing: 10) {
                    Text(title)
                        .font(.custom("Nohemi-Bold", size:22))
                        .foregroundStyle(.white)
                    
                    Text(description)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 16)
                }
                .frame(height: 80, alignment: .top)
               
                
                Divider()
                
                // Select Label - Changed to yellow to match AssessmentLevelView
                Text("Select")
                    .font(.custom("Nohemi-SemiBold", size:20))
                    .foregroundStyle(Color(hex: "fff16c"))
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
            .frame(width: 280, height: 300)
            .padding(.vertical, 40)
            .padding(.horizontal, 30)
            .glassBackgroundEffect()
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccessibilityOptionsView()
}
