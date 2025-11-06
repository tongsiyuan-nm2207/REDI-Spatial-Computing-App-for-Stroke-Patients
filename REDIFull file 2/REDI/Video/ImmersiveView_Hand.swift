import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import ARKit

struct HandImmersiveView: View {
    
    @State private var rootEntity = Entity()
        @State private var arkitSession = ARKitSession()
        @State private var handTracking = HandTrackingProvider()
        
        var body: some View {
            RealityView { content, attachments in
                // Setup video player
                if let videoURL = Bundle.main.url(forResource: "FinalLevel1", withExtension: "aivu") {
                    let player = AVPlayer(url: videoURL)
                    
                    var videoPlayerComponent = VideoPlayerComponent(avPlayer: player)
                    videoPlayerComponent.desiredSpatialVideoMode = .spatial
                    videoPlayerComponent.desiredImmersiveViewingMode = .full
                    videoPlayerComponent.desiredViewingMode = .stereo
                    player.play()
                    
                    let videoEntity = Entity(components: [videoPlayerComponent])
                    rootEntity.addChild(videoEntity)
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
                    // ✅ OneHandView now handles GIF display internally
                    // When GIFs show, OneHandView hides its normal UI
                    OneHandView()
                }
                
                Attachment(id: "HandDisplayView") {
                    // ✅ This view is controlled by OneHandView's state
                    // When GIFs show, we need to hide this externally
                    HandDisplayViewWrapper()
                }
            }
            .task {
                // Start ARKit session for hand tracking
                await startHandTracking()
            }
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

    // ✅ Wrapper to control HandDisplayView visibility based on GIF state
    struct HandDisplayViewWrapper: View {
        // We need access to OneHandView's GIF state to hide this view
        // For now, HandDisplayView will always be visible since OneHandView manages its own visibility
        // If you want HandDisplayView to also hide during GIFs, we'll need shared state
        
        var body: some View {
            HandDisplayView()
        }
    }

    #Preview(immersionStyle: .full) {
        HandImmersiveView()
            .environment(AppModel())
    }
