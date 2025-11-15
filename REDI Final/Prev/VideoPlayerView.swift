//
//  VideoPlayerView.swift
//  Week 10 Code
//
//  Simplified version for visionOS
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    let videoName: String
    let onVideoComplete: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isReady = false
    @State private var hasCompleted = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                // Use AVPlayerViewController wrapped in UIViewControllerRepresentable
                VideoPlayerRepresentable(player: player)
                    .ignoresSafeArea()
                    .opacity(isReady ? 1 : 0)
            }
            
            if !isReady {
                VStack(spacing: 20) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                    
                    Text("Loading video...")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func setupPlayer() {
        print("🎬 Loading: \(videoName)")
        
        // Try to find the video
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")
               ?? Bundle.main.url(forResource: videoName, withExtension: "mov") else {
            print("❌ Video not found, skipping...")
            // If video not found, just continue to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onVideoComplete()
            }
            return
        }
        
        print("✅ Found: \(videoURL.lastPathComponent)")
        
        // Create player
        let playerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.volume = 1.0
        
        self.player = avPlayer
        
        // Observe when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak avPlayer] _ in
            print("✅ Video completed")
            if !hasCompleted {
                hasCompleted = true
                avPlayer?.pause()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onVideoComplete()
                }
            }
        }
        
        // Wait a moment then mark as ready and play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isReady = true
            avPlayer.play()
            print("▶️ Playing video")
        }
    }
    
    private func cleanup() {
        player?.pause()
        NotificationCenter.default.removeObserver(self)
        player = nil
    }
}

// Simple wrapper for AVPlayerViewController
struct VideoPlayerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    VideoPlayerView(videoName: "hand_video") {
        print("Video completed")
    }
}
