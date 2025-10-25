//
//  TwoVoice.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 21/10/25.
//

import SwiftUI

struct TwoVoice: View {
    @State private var promptIndex = 0
    
    let prompts = [
        "Say cross when it's safe to cross."
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 80) {
                Spacer()
                
                // Prompt text
                Text(prompts[promptIndex])
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: promptIndex)
                
                VoiceCardView(onTap: {
                    // Cycle through prompts
                    promptIndex = (promptIndex + 1) % prompts.count
                })
                
                Spacer()
                    .frame(height: 80)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview(windowStyle: .volumetric) {
    TwoVoice()
}
