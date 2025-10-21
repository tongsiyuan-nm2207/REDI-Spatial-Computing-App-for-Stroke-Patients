//
//  AssessmentResultsView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

import SwiftUI

struct AssessmentResultsView: View {
    let marks: Int
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 40) {
                // Title
                Text("Lina Tay's Assessment Results")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                
                // Metrics Cards
                HStack(spacing: 20) {
                    MetricCard(
                        value: "00:03",
                        label: "Average reaction time"
                    )
                    
                    MetricCard(
                        value: "\(marks)/4",
                        label: "Obstacles completed"
                    )
                }
                .padding(.horizontal, 40)
                
                // Action Buttons
                HStack(spacing: 16) {
                    ActionButton(
                        icon: "checkmark.circle",
                        label: "Finish",
                        isPrimary: false
                    )
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        label: "Export as PDF",
                        isPrimary: false
                    )
                }
                .padding(.top, 20)
            }
        }
    }
}

struct MetricCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(value)
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let isPrimary: Bool
    
    var body: some View {
        Button(action: {
            // Action here
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(label)
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .glassBackgroundEffect()
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AssessmentResultsView(marks: 2)
}
