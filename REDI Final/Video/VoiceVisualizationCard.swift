//
//  VoiceVisualizationCard.swift
//  REDI
//
//  Created by Interactive 3D Design on 1/11/25.
//

import SwiftUI

struct VoiceVisualizationCard: View {
    let isRecording: Bool
    @State private var animationAmount = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Microphone icon with recording animation
            ZStack {
                // Pulsing circle when recording
                if isRecording {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.green.opacity(0.3))
                        .scaleEffect(animationAmount)
                        .opacity(2 - animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                        .onAppear {
                            animationAmount = 2.0
                        }
                }
                
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 54))
                    .foregroundStyle(isRecording ? .green : Color(hex: "5237b5"))
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isRecording)
            }
            .frame(width: 100, height: 100)
            
            // Status text
            Text(isRecording ? "Listening..." : "Preparing...")
                .font(.custom("Nohemi-Regular", size: 20))
                .foregroundStyle(Color(hex: "5237b5"))
                .animation(.easeInOut(duration: 0.3), value: isRecording)
        }
        .frame(width: 280, height: 220)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(isRecording ? Color.green.opacity(0.5) : Color(hex: "5237b5").opacity(0.1), lineWidth: isRecording ? 3 : 1)
        )
        .animation(.easeInOut(duration: 0.3), value: isRecording)
    }
}

#Preview(windowStyle: .volumetric) {
    VStack(spacing: 40) {
        VoiceVisualizationCard(isRecording: false)
        VoiceVisualizationCard(isRecording: true)
    }
}
