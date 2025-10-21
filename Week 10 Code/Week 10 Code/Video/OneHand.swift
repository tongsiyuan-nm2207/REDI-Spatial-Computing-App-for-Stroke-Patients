//
//  OneHand.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI
import AVKit
import AVFoundation
import RealityKit

struct OneHandView: View {
    @State private var clickCount = 0
    @State private var marks = 0
    @State private var showingResults = false
    @State private var player: AVPlayer?
    
    let prompts = [
        "What's in front of you?",
        "What is the current colour of the traffic light?",
        "Which side are cars parked?",
        "What is the bus number of this bus?"
    ]
    
    var body: some View {
        ZStack {
            // Immersive Video Background
            if let player = player {
                ImmersiveVideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            
            // UI Layer
            if !showingResults {
                ZStack {
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
                AssessmentResultsView(marks: marks)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingResults)
        .onAppear {
            setupImmersiveVideo()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupImmersiveVideo() {
        guard let videoURL = Bundle.main.url(forResource: "Level 1 Final 1", withExtension: "aivu") else {
            print("❌ Video file not found: Level 1 Final 1.aivu")
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Configure for immersive video

        
        // Play the video
        player?.play()
        
        // Optional: Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        print("✅ Immersive video loaded successfully")
    }
}

struct ImmersiveVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.videoGravity = .resizeAspectFill
        return playerView
    }
    
    func updateUIView(_ uiView: AVPlayerView, context: Context) {
        uiView.player = player
    }
}

class AVPlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoGravity: AVLayerVideoGravity {
        get {
            return playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }
}

#Preview(windowStyle: .volumetric) {
    OneHandView()
}
