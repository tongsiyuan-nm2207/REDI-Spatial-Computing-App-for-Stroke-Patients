import SwiftUI

struct HandDisplayView: View {
    @ObservedObject var handState = HandStateManager.shared
    
    var body: some View {
        VStack(spacing: 15) {
            // Left Hand Info
            HStack {
                Text("Left Hand:")
                    .foregroundColor(.white)
                Text(String(format: "%.3fm", handState.leftHandHeight))
                    .foregroundColor(.white)
                Text("(\(handState.leftHandLifted ? "True" : "False"))")
                    .foregroundColor(handState.leftHandLifted ? .green : .red)
                    .fontWeight(.semibold)
            }
            
            // Right Hand Info
            HStack {
                Text("Right Hand:")
                    .foregroundColor(.white)
                Text(String(format: "%.3fm", handState.rightHandHeight))
                    .foregroundColor(.white)
                Text("(\(handState.rightHandLifted ? "True" : "False"))")
                    .foregroundColor(handState.rightHandLifted ? .green : .red)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 36)
        .glassBackgroundEffect()
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HandDisplayView()
}
