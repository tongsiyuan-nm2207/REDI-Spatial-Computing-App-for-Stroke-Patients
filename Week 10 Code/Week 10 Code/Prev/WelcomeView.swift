
//
//  WelcomeView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

// can have a back button for these Prev views... haven't put yet

import SwiftUI

struct WelcomeView: View {
    @State private var isShowingAccessibilityOptionsView = false
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !isShowingAccessibilityOptionsView {
                VStack(spacing: 40) {
                    // Title
                    Text("Welcome to REDI")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    
                    // Welcome Card
                    VStack(spacing: 5) {
                        // Welcome Image
                        Image("WelcomePicture")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .clipped()
                        
                        // Description Text
                        VStack(spacing: 16) {
                            Text("REDI is a stroke readiness assessment that will help your doctors understand your strengths and support your progress.")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                            
                            Text("Take your time, and do your best!")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 24)
                        
                        Divider()
                            .padding(.top, 20)
                        
                        // Begin Button
                        Button(action: {
                            isShowingAccessibilityOptionsView = true
                        }) {
                            Text("Begin")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 0)
                                .background(.white.opacity(0))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                    .frame(width: 520)
                    .glassBackgroundEffect()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .transition(.opacity)
            } else {
                AccessibilityOptionsView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowingAccessibilityOptionsView)
    }
}

#Preview {
    WelcomeView()
}
