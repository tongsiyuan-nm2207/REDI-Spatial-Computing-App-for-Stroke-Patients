//
//  ObstaclePieChart.swift
//  simulation
//
//  Created by Interactive 3D Design on 24/9/25.
//

import SwiftUI

struct ObstaclePieChart: View {
    var body: some View {
        ZStack {
            // Background circle (remaining portion)
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            // Progress circle (completed portion)
            Circle()
                .trim(from: 0, to: 0.6) // 3/5 = 0.6
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            // Center text
            VStack(spacing: 4) {
                Text("3/5")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("obstacles")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: 200, height: 200)
    }
}

#Preview {
    ObstaclePieChart()
}
