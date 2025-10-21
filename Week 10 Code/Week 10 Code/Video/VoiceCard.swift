//
//  VoiceCard.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI

struct VoiceCardView: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 16) {
                // Microphone icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 82))
                    .foregroundStyle(.white)
                
                // Instruction text
                Text("Speak to answer")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: 360, height: 260)
            .glassBackgroundEffect()
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 0)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview(windowStyle: .volumetric) {
    VoiceCardView(onTap: {})
}
