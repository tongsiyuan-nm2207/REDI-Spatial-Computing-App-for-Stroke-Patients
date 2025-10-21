//
//  HandCard.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI

struct HandCardView: View {
    @State private var selectedOption: String?
    @Binding var clickCount: Int
    @Binding var marks: Int
    @Binding var showingResults: Bool

    var options: [(String, String)] {
        switch clickCount {
        case 0:
            return [
                ("Zebra crossing", "Lift your left arm"),
                ("Traffic light", "Lift your right arm")
            ]
        case 1:
            return [
                ("Green", "Lift your left arm"),
                ("Red", "Lift your right arm")
            ]
        case 2:
            return [
                ("Left", "Lift your left arm"),
                ("Right", "Lift your right arm")
            ]
        default: // case 3 and beyond
            return [
                ("48", "Lift your left arm"),
                ("61", "Lift your right arm")
            ]
        }
    }
    
    // Right-situated cards that should give points
    let rightCards = ["Traffic light", "Red", "Right", "61"]
    
    // Final cards that trigger navigation
    let finalCards = ["48", "61"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Choice cards
                HStack(spacing: 20) {
                    ForEach(options, id: \.0) { option in
                        ChoiceCard(
                            title: option.0,
                            subtitle: option.1,
                            isSelected: selectedOption == option.0
                        )
                        .onTapGesture {
                            selectedOption = option.0
                            clickCount += 1
                            
                            // Add mark if right card is clicked
                            if rightCards.contains(option.0) {
                                marks += 1
                            }
                            
                            // Navigate to results if final card is clicked
                            if finalCards.contains(option.0) {
                                showingResults = true
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 60)
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChoiceCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
            
            Text(subtitle)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 240, height: 140)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .stroke(isSelected ? .white.opacity(0.5) : .white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    HandCardView(clickCount: .constant(0), marks: .constant(0), showingResults: .constant(false))
}
