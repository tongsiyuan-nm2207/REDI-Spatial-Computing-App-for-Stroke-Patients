import SwiftUI
import RealityKit
import AVFoundation

struct VoiceImmersiveView: View {
    @State private var rootEntity = Entity()
    @State private var avPlayer: AVPlayer?  // ✅ Store player reference
    @State private var videoEntity: Entity?  // ✅ Store video entity reference
    
    // Speech recognition using @Observable
    @State private var speechManager = GameSpeechManager()
    
    // Environment for dismissing immersive space
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AssessmentState.self) private var assessmentState
    
    var body: some View {
        RealityView { content, attachments in
            // Set up the immersive video player - only once
            if avPlayer == nil {
                let player = AVPlayer(url: Bundle.main.url(forResource: "FinalLevel1", withExtension: "aivu")!)
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
            
            // Add the OneVoice UI attachment
            if let uiAttachment = attachments.entity(for: "oneVoiceUI") {
                uiAttachment.position = [0, 0.75, -1.5]
                rootEntity.addChild(uiAttachment)
            }
            
        } update: { content, attachments in
            // Update the UI attachment position when needed
            if let uiAttachment = attachments.entity(for: "oneVoiceUI") {
                uiAttachment.position = [0, 0.75, -1.5]
            }
            
        } attachments: {
            Attachment(id: "oneVoiceUI") {
                // ✅ Pass stopVideo callback to OneVoiceView
                OneVoiceView(
                    speechManager: speechManager,
                    stopVideoAction: stopVideo
                )
            }
        }
        .onAppear {
            // Start speech recognition when view appears
            if !speechManager.model.isRecording {
                speechManager.toggleRecording()
            }
        }
        .onDisappear {
            // Stop speech recognition when view disappears
            if speechManager.model.isRecording {
                speechManager.toggleRecording()
            }
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
}

#Preview(immersionStyle: .full) {
    VoiceImmersiveView()
        .environment(AppModel())
        .environment(AssessmentState())
}
