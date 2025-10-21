//
//  OneVoice.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI

struct OneVoice: View {
    @State private var promptIndex = 0
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are the cars parked?",
        "What is the bus number of this bus?"
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 80) {
                Spacer()
                
                // Prompt text
                Text(prompts[promptIndex])
                    .font(.system(size: 48, weight: .semibold))
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
    OneVoice()
}
