import SwiftUI

struct AssessmentLevelView: View {
    let accessibilityMode: AccessibilityMode
    @State private var isShowingOneVoice = false
    @State private var selectedLevel: Int = 1
    
    // Environment variables should be here, inside the struct
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isShowingOneVoice {
                VStack(spacing: 50) {
                    // Title
                    Text("Please select a level of assessment")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    // Level Cards
                    HStack(spacing: 50) {
                        // Notice Level - ⌘+1
                        AssessmentLevelCard(
                            number: "1",
                            title: "NOTICE",
                            description: "Take note of details in your environment",
                            onSelect: {
                                selectedLevel = 1
                                isShowingOneVoice = true
                            }
                        )
                        .keyboardShortcut("1", modifiers: .command)  // ⌘+1 for Level 1
                        
                        // React Level - ⌘+2
                        AssessmentLevelCard(
                            number: "2",
                            title: "REACT",
                            description: "Take note of details and react to changes in your environment",
                            onSelect: {
                                selectedLevel = 2
                                isShowingOneVoice = true
                            }
                        )
                        .keyboardShortcut("2", modifiers: .command)  // ⌘+2 for Level 2
                        
                        // Act Level - ⌘+3
                        AssessmentLevelCard(
                            number: "3",
                            title: "ACT",
                            description: "React to your environment to ensure personal safety",
                            onSelect: {
                                selectedLevel = 3
                                isShowingOneVoice = true
                            }
                        )
                        .keyboardShortcut("3", modifiers: .command)  // ⌘+3 for Level 3
                    }
                }
                .transition(.opacity)
            } else {
                // Navigate to immersive spaces based on accessibility mode and level
                Group {
                    if accessibilityMode == .voiceActivated && selectedLevel == 1 {
                        VStack {
                        }
                        .task {
                            await openImmersiveSpace(id: "VoiceImmersiveSpace")
                        }
                    } else if accessibilityMode == .armDetection && selectedLevel == 1 {
                        VStack {
                        }
                        .task {
                            await openImmersiveSpace(id: "HandImmersiveSpace")
                        }
                    } else if accessibilityMode == .voiceActivated && selectedLevel == 2 {
                        VStack {
                            // Placeholder for Voice Level 2
                        }
                        .task {
                            // TODO: Implement VoiceImmersiveSpace Level 2
                            print("Voice Level 2 - Not yet implemented")
                            // await openImmersiveSpace(id: "VoiceImmersiveSpaceLevel2")
                        }
                    } else if accessibilityMode == .armDetection && selectedLevel == 2 {
                        VStack {
                            // Placeholder for Arm Detection Level 2
                        }
                        .task {
                            // TODO: Implement HandImmersiveSpace Level 2
                            print("Arm Detection Level 2 - Not yet implemented")
                            // await openImmersiveSpace(id: "HandImmersiveSpaceLevel2")
                        }
                    } else if accessibilityMode == .voiceActivated && selectedLevel == 3 {
                        VStack {
                            // Placeholder for Voice Level 3
                        }
                        .task {
                            // TODO: Implement VoiceImmersiveSpace Level 3
                            print("Voice Level 3 - Not yet implemented")
                            // await openImmersiveSpace(id: "VoiceImmersiveSpaceLevel3")
                        }
                    } else if accessibilityMode == .armDetection && selectedLevel == 3 {
                        VStack {
                            // Placeholder for Arm Detection Level 3
                        }
                        .task {
                            // TODO: Implement HandImmersiveSpace Level 3
                            print("Arm Detection Level 3 - Not yet implemented")
                            // await openImmersiveSpace(id: "HandImmersiveSpaceLevel3")
                        }
                    }
                }
                .transition(.opacity)
            }
        } // <- This closes ZStack
    } // <- This closes body
} // <- This closes AssessmentLevelView

struct AssessmentLevelCard: View {
    let number: String
    let title: String
    let description: String
    let onSelect: () -> Void
    
    var body: some View {
        // The entire card is a button so keyboard shortcut applies to whole card
        Button(action: onSelect) {
            VStack(spacing: 20) {
                // Number Circle
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 67)
                    
                    Text(number)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.4))
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                // Title
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                
                // Description
                Text(description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Divider()
                
                // Select Label (not a separate button anymore)
                Text("Select")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
            }
            .frame(width: 280, height: 280)
            .padding(.vertical, 40)
            .padding(.horizontal, 30)
            .glassBackgroundEffect()
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AssessmentLevelView(accessibilityMode: .voiceActivated)
}
