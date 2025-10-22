//
//  OneHand.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct OneHandView: View {
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var showingResults = false
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are cars parked?",
        "What is the bus number of this bus?"
    ]
    
    var body: some View {
        ZStack {
            Color.clear
            
            if !showingResults {
                ZStack {
                    // 360° Immersive Video Background (only when not showing results)
                    Immersive360VideoView()
                        .ignoresSafeArea()
                    
                    // Marks View in top-right corner
                    VStack {
                        HStack {
                            Spacer()
                            MarksView(marks: $marks)
                                .padding(.top, 40)
                                .padding(.trailing, 40)
                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 80) {
                        Spacer()
                        
                        // Prompt text
                        Text(prompts[min(clickCount, prompts.count - 1)])
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.3), value: clickCount)
                        
                        HandCardView(clickCount: $clickCount, marks: $marks, showingResults: $showingResults)
                        
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .transition(.opacity)
            } else {
                // No immersive video in results view
                AssessmentResultsView(marks: marks)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingResults)
    }
}

struct Immersive360VideoView: View {
    var body: some View {
        RealityView { content in
            guard let videoURL = Bundle.main.url(forResource: "Level 1 Final 1", withExtension: "aivu") else {
                print("❌ Video file not found: Level 1 Final 1.aivu")
                return
            }
            
            // Create AVPlayer
            let player = AVPlayer(url: videoURL)
            
            // Create video material
            let videoMaterial = VideoMaterial(avPlayer: player)
            
            // Create a large sphere (inside-out for 360° effect)
            let sphereMesh = MeshResource.generateSphere(radius: 50)
            
            // Create entity with video material
            let videoEntity = ModelEntity(mesh: sphereMesh, materials: [videoMaterial])
            
            // Flip the sphere inside-out so we see the video from inside
            videoEntity.scale = [1, 1, -1]
            
            // Position at origin (user will be inside)
            videoEntity.position = [0, 0, 0]
            
            // Add to scene
            content.add(videoEntity)
            
            // Start playback
            player.play()
            
            // Optional: Loop video
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            
            print("✅ 360° Immersive video loaded successfully")
        }
    }
}

#Preview(windowStyle: .volumetric) {
    OneHandView()
}
