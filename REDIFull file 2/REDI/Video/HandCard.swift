import SwiftUI

struct HandCardView: View {
    @State private var selectedOption: String?
    @State private var lastLeftHandState = false
    @State private var lastRightHandState = false
    @State private var leftHandHoldStart: Date?
    @State private var rightHandHoldStart: Date?
    @State private var holdTimer: Timer?
    @Binding var clickCount: Int
    @Binding var marks: Int
    @Binding var showingResults: Bool
    let onCardTap: () -> Void
    
    @ObservedObject var handState = HandStateManager.shared
    
    private let requiredHoldDuration: TimeInterval = 3.0

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
                ("5", "Lift your left arm"),
                ("3", "Lift your right arm")
            ]
        default: // case 3 and beyond
            return [
                ("970", "Lift your left arm"),
                ("67", "Lift your right arm")
            ]
        }
    }
    
    // Right-situated cards that should give points
    let rightCards = ["Zebra crossing", "Red", "3", "970"]
    
    // Final cards that trigger navigation
    let finalCards = ["970", "67"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                // Choice cards
                HStack(spacing: 40) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        ChoiceCard(
                            title: option.0,
                            subtitle: option.1,
                            isSelected: selectedOption == option.0
                        )
                    }
                }
                
                Spacer()
                    .frame(height: 60)
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: handState.leftHandLifted) { oldValue, newValue in
            if newValue && !lastLeftHandState {
                // Hand just lifted - start timer
                print("🫲 Left hand lifted - starting hold timer")
                leftHandHoldStart = Date()
                startHoldTimer()
            } else if !newValue && lastLeftHandState {
                // Hand lowered - cancel timer
                print("🫲 Left hand lowered - canceling timer")
                leftHandHoldStart = nil
            }
            lastLeftHandState = newValue
        }
        .onChange(of: handState.rightHandLifted) { oldValue, newValue in
            if newValue && !lastRightHandState {
                // Hand just lifted - start timer
                print("🫱 Right hand lifted - starting hold timer")
                rightHandHoldStart = Date()
                startHoldTimer()
            } else if !newValue && lastRightHandState {
                // Hand lowered - cancel timer
                print("🫱 Right hand lowered - canceling timer")
                rightHandHoldStart = nil
            }
            lastRightHandState = newValue
        }
        .onDisappear {
            stopHoldTimer()
        }
    }
    
    private func startHoldTimer() {
        // Stop existing timer if any
        stopHoldTimer()
        
        // Create a new timer that checks every 0.1 seconds
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkHoldDuration()
        }
    }
    
    private func stopHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
    
    private func checkHoldDuration() {
        let now = Date()
        
        // Check left hand hold duration
        if let leftStart = leftHandHoldStart,
           handState.leftHandLifted,
           now.timeIntervalSince(leftStart) >= requiredHoldDuration {
            print("✅ Left hand held for 3 seconds!")
            handleCardSelection(options[0].0)
            leftHandHoldStart = nil
            stopHoldTimer()
            return
        }
        
        // Check right hand hold duration
        if let rightStart = rightHandHoldStart,
           handState.rightHandLifted,
           now.timeIntervalSince(rightStart) >= requiredHoldDuration {
            print("✅ Right hand held for 3 seconds!")
            handleCardSelection(options[1].0)
            rightHandHoldStart = nil
            stopHoldTimer()
            return
        }
    }
    
    private func handleCardSelection(_ option: String) {
        selectedOption = option
        // ✅ Don't increment clickCount - let the parent's master timer handle progression
        
        // Add mark if right card is clicked
        if rightCards.contains(option) {
            marks += 1
            print("✅ Correct answer! Mark awarded. Total marks: \(marks)")
        }
        
        // ✅ Don't check finalCards or set showingResults - let parent handle this
        
        // Notify parent that an answer was selected
        onCardTap()
    }
}

struct ChoiceCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            
            Text(subtitle)
                .font(.system(size: 18))
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
    HandCardView(
        clickCount: .constant(0),
        marks: .constant(0),
        showingResults: .constant(false),
        onCardTap: {}
    )
}
