//
//  HelpView.swift
//  simulation
//
//  Created by Interactive 3D Design on 28/9/25.
//

//
//  HelpView.swift
//  simulation
//
//  Created by Seidl Kim on 26/9/25.
//
//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct HelpView: View {
//    var body: some View {
//        HStack(spacing: 20) {
//            // Information section
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Information")
//                    .font(.largeTitle)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//
//                Text("FINI is a digital stroke readiness assessment.\nSelect the icons to learn more.")
//                    .font(.system(size: 20))
//                    .foregroundColor(.white.opacity(0.9))
//                    .lineSpacing(2)
//            }
//        }
//        .padding(.horizontal, 24)
//        .padding(.vertical, 20)
//        .glassBackgroundEffect()
//        .cornerRadius(20)
//
//        }
//    }
//
//#Preview {
//HelpView()
//}

import SwiftUI
import RealityKit
import RealityKitContent

struct HelpView: View {
    @State private var isListening = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Help")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Need assistance with FINI? We're here to help.")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(2)
                }
                .padding(.horizontal,20)
                
                // Speak to chat button
                Button(action: {
                    toggleListening()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .font(.title2)
                            .foregroundColor(.white)
                            .scaleEffect(isListening ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isListening)
                        
                        Text("Speak to chat")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .glassBackgroundEffect()
            .cornerRadius(20)
        }
    }
    
    private func toggleListening() {
        isListening.toggle()
        
        // Simulate listening for 3 seconds then stop
        if isListening {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isListening = false
            }
        }
    }
}

// Standalone component version (without background)
struct SpeakToChatCard: View {
    @State private var isListening = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                Text("Help")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Need assistance with FINI? We're here to help.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(nil)
            }
            
            // Speak to chat button
            Button(action: {
                toggleListening()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundColor(.white)
                        .scaleEffect(isListening ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isListening)
                    
                    Text("Speak to chat")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .glassBackgroundEffect()
        .cornerRadius(20)
    }
    
    
    private func toggleListening() {
        isListening.toggle()
        
        // Add spatial audio feedback for visionOS
#if os(visionOS)
        // Use spatial audio or visual feedback instead of haptics
#elseif os(iOS)
        // Add haptic feedback for iOS
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
#endif
        
        // Simulate listening for 3 seconds then stop
        if isListening {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isListening = false
            }
        }
    }
}
    
    
    //// Example usage
    //struct ContentView: View {
    //    var body: some View {
    //        VStack(spacing: 30) {
    //            Text("Full Screen Version:")
    //                .foregroundColor(.white)
    //                .font(.headline)
    //
    //            SpeakToChatView()
    //                .frame(height: 300)
    //
    //            Text("Card Component Version:")
    //                .foregroundColor(.white)
    //                .font(.headline)
    //
    //            SpeakToChatCard()
    //        }
    //        .padding()
    //        .background(Color.black)
    //    }
    //}
    
    #Preview {
        HelpView()
    }
