import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import ARKit

struct HandImmersiveView: View {
    
    @State private var rootEntity = Entity()
    @State private var arkitSession = ARKitSession()
    @State private var handTracking = HandTrackingProvider()
    
    // ✅ Store AVPlayer and video entity references
    @State private var avPlayer: AVPlayer?
    @State private var videoEntity: Entity?
    
    var body: some View {
        RealityView { content, attachments in
            // Setup video player
            if let videoURL = Bundle.main.url(forResource: "FinalLevel1", withExtension: "aivu") {
                let player = AVPlayer(url: videoURL)
                
                // ✅ Store the player reference
                avPlayer = player
                
                var videoPlayerComponent = VideoPlayerComponent(avPlayer: player)
                videoPlayerComponent.desiredSpatialVideoMode = .spatial
                videoPlayerComponent.desiredImmersiveViewingMode = .full
                videoPlayerComponent.desiredViewingMode = .stereo
                player.play()
                
                let entity = Entity(components: [videoPlayerComponent])
                
                // ✅ Store video entity reference
                videoEntity = entity
                
                rootEntity.addChild(entity)
            }
            
            content.add(rootEntity)
            
            // Add hand tracking entities
            makeHandEntities(in: content)
            
            // Add the combined UI attachment (includes OneHandView with GIF support)
            if let mainUIEntity = attachments.entity(for: "MainUI") {
                mainUIEntity.components.set(BillboardComponent())
                rootEntity.addChild(mainUIEntity)
                mainUIEntity.setPosition(SIMD3<Float>(0, 0.9, -1.5), relativeTo: rootEntity)
            }
            
            // Add the HandDisplayView UI attachment (below main UI)
            if let handDisplayEntity = attachments.entity(for: "HandDisplayView") {
                handDisplayEntity.components.set(BillboardComponent())
                rootEntity.addChild(handDisplayEntity)
                handDisplayEntity.setPosition(SIMD3<Float>(0, 0.4, -1.5), relativeTo: rootEntity)
            }
            
        } update: { content, attachments in
            // Update attachment positions if needed
            if let mainUIEntity = attachments.entity(for: "MainUI") {
                mainUIEntity.setPosition(SIMD3<Float>(0, 0.9, -1.5), relativeTo: rootEntity)
            }
            
            if let handDisplayEntity = attachments.entity(for: "HandDisplayView") {
                handDisplayEntity.setPosition(SIMD3<Float>(0, 0.4, -1.5), relativeTo: rootEntity)
            }
            
        } attachments: {
            Attachment(id: "MainUI") {
                // ✅ Pass stopVideo callback to OneHandView
                OneHandView(stopVideoAction: stopVideo)
            }
            
            Attachment(id: "HandDisplayView") {
                HandDisplayViewWrapper()
            }
        }
        .task {
            // Start ARKit session for hand tracking
            await startHandTracking()
        }
    }
    
    // ✅ Function to stop and remove video, revealing passthrough
    private func stopVideo() {
        guard let player = avPlayer, let entity = videoEntity else { return }
        print("🎬 Stopping video and removing from scene - passthrough will be visible")
        
        // Stop the video
        player.pause()
        
        // Remove video entity from the scene - this reveals passthrough
        entity.removeFromParent()
        
        print("✅ Video entity removed - passthrough now visible")
    }
    
    /// Starts the ARKit session with hand tracking
    @MainActor
    func startHandTracking() async {
        do {
            // Check if hand tracking is supported
            if HandTrackingProvider.isSupported {
                try await arkitSession.run([handTracking])
                print("✅ Hand tracking started successfully")
            } else {
                print("⚠️ Hand tracking not supported on this device")
            }
        } catch {
            print("❌ Failed to start ARKit session: \(error)")
        }
    }
    
    /// Creates the entity that contains all hand-tracking entities.
    @MainActor
    func makeHandEntities(in content: any RealityViewContentProtocol) {
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        
        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
}

// Wrapper to control HandDisplayView visibility based on GIF state
struct HandDisplayViewWrapper: View {
    var body: some View {
        HandDisplayView()
    }
}

#Preview(immersionStyle: .full) {
    HandImmersiveView()
        .environment(AppModel())
}
