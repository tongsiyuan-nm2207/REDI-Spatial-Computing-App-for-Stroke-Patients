//
//  AssessmentLevelView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//
import SwiftUI

struct AssessmentLevelView: View {
    let accessibilityMode: AccessibilityMode
    @State private var isShowingOneVoice = false
    @State private var selectedLevel: Int = 1
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isShowingOneVoice  {
                VStack(spacing: 40) {
                    // Title
                    Text("Please select a level of assessment")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    // Level Cards
                    HStack(spacing: 25) {
                        // Notice Level
                        AssessmentLevelCard(
                            number: "1",
                            title: "NOTICE",
                            description: "Take note of details in your environment",
                            onSelect: {
                                selectedLevel = 1
                                isShowingOneVoice  = true
                            }
                        )
                        
                        // React Level
                        AssessmentLevelCard(
                            number: "2",
                            title: "REACT",
                            description: "Take note of details and react to changes in your environment",
                            onSelect: {
                                selectedLevel = 2
                                isShowingOneVoice  = true
                            }
                        )
                        
                        // Act Level
                        AssessmentLevelCard(
                            number: "3",
                            title: "ACT",
                            description: "React to your environment to ensure personal safety",
                            onSelect: {
                                selectedLevel = 3
                                isShowingOneVoice  = true
                            }
                        )
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.opacity)
            } else {
                // Navigate to different ContentView based on accessibility mode and level
                Group {
                    if accessibilityMode == .voiceActivated && selectedLevel == 1 {
                        OneVoice ()
                    } else if accessibilityMode == .armDetection && selectedLevel == 1 {
                        OneHandView()
                    } else if accessibilityMode == .voiceActivated && selectedLevel == 2 {
                        ContentView3()
                    } else if accessibilityMode == .armDetection && selectedLevel == 2 {
                        ContentView4()
                    } else if accessibilityMode == .voiceActivated && selectedLevel == 3 {
                        ContentView5()
                    } else if accessibilityMode == .armDetection && selectedLevel == 3 {
                        ContentView6()
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowingOneVoice )
    }
}

struct AssessmentLevelCard: View {
    let number: String
    let title: String
    let description: String
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Number Circle
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 80, height: 80)
                
                Text(number)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.7))
            }
            
            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            // Description
            Text(description)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 30, alignment: .top)
            
            Spacer()
            
            Divider()
            
            // Select Button
            Button(action: {
                onSelect()
            }) {
                Text("Select")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .frame(width: 280, height: 280)
        .padding(.vertical, 40)
        .padding(.horizontal, 28)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    AssessmentLevelView(accessibilityMode: .voiceActivated)
}
