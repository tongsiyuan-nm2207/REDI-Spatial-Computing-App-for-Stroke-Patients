//
//  CustomProgressBar.swift
//  simulation
//
//  Created by Interactive 3D Design on 24/9/25.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let greenMarkerPosition: Double // 0.0 to 1.0
    let whiteMarkerPosition: Double // 0.0 to 1.0
    let redMarkerPosition: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 30)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * progress, height: 30)
                
                // Green marker
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 30)
                    .offset(x: geometry.size.width * greenMarkerPosition - 1.5)
                
                // White marker
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3, height: 30)
                    .offset(x: geometry.size.width * whiteMarkerPosition - 1.5)
                
                // Red marker
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 3, height: 30)
                    .offset(x: geometry.size.width * redMarkerPosition - 1.5)
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    CustomProgressBar(
        progress: 0.55,
        greenMarkerPosition: 0.20,
        whiteMarkerPosition: 0.35,
        redMarkerPosition: 0.65
    )
    .padding()
}
