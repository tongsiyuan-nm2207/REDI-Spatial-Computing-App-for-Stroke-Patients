//
//  InformationView.swift
//  simulation
//
//  Created by Interactive 3D Design on 28/9/25.
//

//
//  InformationView.swift
//  simulation
//
//  Created by Seidl Kim on 26/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct InformationView: View {
    var body: some View {
        HStack(spacing: 20) {
                    // Information section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Information")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("FINI is a digital stroke readiness assessment.\nSelect the icons to learn more.")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal,20)
                    
            Spacer()
                .frame(width:30)
                    
                    // Icon sections
                    HStack {
                        // Inclusive icon (accessibility symbol)
                        VStack(spacing: 16) {
                            Button(action: {
                                // Action for inclusive
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    // Custom accessibility icon
                                    Image(systemName: "accessibility")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Text("Inclusive")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Immersive icon (VR/AR symbol)
                        VStack(spacing: 16) {
                            Button(action: {
                                // Action for immersive
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    // VR headset representation
                                    Image(systemName: "visionpro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Text("Immersive")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Tracking icon
                        VStack(spacing: 16) {
                            Button(action: {
                                // Action for tracking
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                                .frame(width: 52, height: 52)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Text("Tracking")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
                .glassBackgroundEffect()
                .cornerRadius(20)
                
            }
        }
#Preview {
    InformationView()
}

// Example usage in a view
//struct ContentView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            InfomationView()
//
//            Text("Alternative with different icons:")
//                .foregroundColor(.secondary)
//
//            InfomationViewCustomIcons()
//        }
//        .padding()
//        .background(Color.black) // Dark background to show the banner
//    }
//}
//
//#Preview {
//    ContentView()
//}
