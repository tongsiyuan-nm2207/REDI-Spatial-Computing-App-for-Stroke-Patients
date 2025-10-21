//
//  Marks.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI

struct MarksView: View {
    @Binding var marks: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Score")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            
            Text("\(marks)")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .frame(width: 200, height: 180)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    MarksView(marks: .constant(3))
}
