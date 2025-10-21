
//
//  AirDropSuccessView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

import SwiftUI

struct AirDropSuccessView: View {
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 40) {
                // Title
                Text("Lina Tay's Assessment Results")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                
                // Success Card
                VStack(spacing: 14) {
                    // AirDrop Icon
                    Image("AirDrop_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .opacity(0.7)
                    
                    // Success Message
                    VStack(spacing: 2) {
                        Text("Lina Tay's")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("Assessment Results")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Successful AirDrop to")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text("Dr Lim's iPhone.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                        
                    }
                    .padding(.top, 4)
                    
                    Divider()
                    
                    // Complete Button
                    Button(action: {
                        // Complete action
                    }) {
                        Text("Complete")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 0)
                            //.background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                }
                .frame(width: 480)
                .padding(.vertical, 38)
                .padding(.horizontal,10)
                .glassBackgroundEffect()
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
        }
    }
}

#Preview {
    AirDropSuccessView()
}
