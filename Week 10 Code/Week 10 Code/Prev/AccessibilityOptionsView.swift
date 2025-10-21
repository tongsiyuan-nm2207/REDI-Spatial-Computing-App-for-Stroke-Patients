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
    @State private var isShowingAssessmentLevelView = false
    @State private var selectedMode: AccessibilityMode = .voiceActivated
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isShowingAssessmentLevelView {
                VStack(spacing: 40) {
                    // Title
                    Text("Please select an accessibility option")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    // Option Cards
                    HStack(spacing: 30) {
                        // Voice Activated Card
                        AccessibilityOptionCard(
                            icon: "waveform.circle.fill",
                            title: "Voice activated",
                            description: "Speak to answer during the assessment",
                            onSelect: {
                                selectedMode = .voiceActivated
                                isShowingAssessmentLevelView = true
                            }
                        )
                        
                        // Arm Detection Card
                        AccessibilityOptionCard(
                            icon: "hand.raised.fill",
                            title: "Arm detection",
                            description: "Raise your arm to select answers during the assessment",
                            onSelect: {
                                selectedMode = .armDetection
                                isShowingAssessmentLevelView = true
                            }
                        )
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.opacity)
            } else {
                AssessmentLevelView(accessibilityMode: selectedMode)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowingAssessmentLevelView)
    }
}

struct AccessibilityOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .frame(width: 100, height: 100)
                .background(Circle().fill(.white.opacity(0.2)))
            
            // Text Content
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 80, alignment: .top)
           
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
            .padding(.horizontal, 30)
            .padding(.top, 8)
        }
        .frame(width: 340, height: 300)
        .padding(.vertical, 48)
        .padding(.horizontal, 32)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    AccessibilityOptionsView()
}
