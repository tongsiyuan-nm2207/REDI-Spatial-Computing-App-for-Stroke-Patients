//
//  AirDropSuccessView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

import SwiftUI

struct AirDropSuccessView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 40) {
                // Success Card
                VStack(spacing: 20) {
                    // AirDrop Icon
                    Image("AirDrop_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .opacity(0.7)
                        .padding(.bottom,10)
                    
                    // Success Message
                    VStack {
                        Text("Lina Tay's")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("Assessment Results")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Successful AirDrop to")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text("Dr Lim's iPhone.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.bottom,10)
                        
                    }
                    .padding(.top, 4)
                    
                    Divider()
                    
                    // Complete Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Text("Complete")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 0)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                }
                .frame(width: 480)
                .padding(.vertical, 40)
                .padding(.horizontal,0)
                .glassBackgroundEffect()
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
        }
    }
}

#Preview {
    AirDropSuccessView(isPresented: .constant(true))
}

