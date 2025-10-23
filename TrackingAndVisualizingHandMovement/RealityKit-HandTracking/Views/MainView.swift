/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main view.
*/
/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The app's main view.
*/

import SwiftUI

struct MainView: View {
    /// The environment value to get the `OpenImmersiveSpaceAction` instance.
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    /// Observe hand state changes
    @ObservedObject var handState = HandStateManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Hand Tracking Example")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            
            // Left Hand Info
            VStack(alignment: .leading, spacing: 10) {
                Text("Left Hand")
                    .font(.headline)
                
                HStack {
                    Text("Height:")
                    Text(String(format: "%.3fm (%.1fcm)", handState.leftHandHeight, handState.leftHandHeight * 100))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Lifted:")
                    Text(handState.leftHandLifted ? "true" : "false")
                        .foregroundColor(handState.leftHandLifted ? .green : .red)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Right Hand Info
            VStack(alignment: .leading, spacing: 10) {
                Text("Right Hand")
                    .font(.headline)
                
                HStack {
                    Text("Height:")
                    Text(String(format: "%.3fm (%.1fcm)", handState.rightHandHeight, handState.rightHandHeight * 100))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Lifted:")
                    Text(handState.rightHandLifted ? "true" : "false")
                        .foregroundColor(handState.rightHandLifted ? .green : .red)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            Task {
                await openImmersiveSpace(id: "HandTrackingScene")
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
}
