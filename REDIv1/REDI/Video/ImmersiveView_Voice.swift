import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import Speech
import Observation

/// Game states for the cube challenge
enum GameState2 {
    case waiting    // 5 second wait before cube appears
    case active     // 30 second challenge window
    case showingResult // 10 second result display
}

/// Mark this as `@Observable` so that SwiftUI calls `update:` on the `RealityView` when it changes.
@Observable
class TappedComponent2: Component {
    var gameState: GameState2 = .waiting
    var countdownTime: Int = 30  // CHANGE THIS NUMBER TO ADJUST 30-second window
    var resultMessage: String = ""
    var cubeVisible: Bool = false
    var wasTapped: Bool = false
    var reactionStartTime: Date?
    var reactionTime: Double?
}

struct VoiceImmersiveView: View {
    
    @State private var rootEntity = Entity()
    @State private var cubeEntity: Entity?
    @State private var speechManager = GameSpeechManager()
    
    var body: some View {
        RealityView { content, attachments in
            // Setup video player
            let player = AVPlayer(url: Bundle.main.url(forResource: "Level1", withExtension: "aivu")!)
            
            var videoPlayerComponent = VideoPlayerComponent(avPlayer: player)
            videoPlayerComponent.desiredSpatialVideoMode = .spatial
            videoPlayerComponent.desiredImmersiveViewingMode = .full
            videoPlayerComponent.desiredViewingMode = .stereo
            player.play()

            let videoEntity = Entity(components: [videoPlayerComponent])

            // Load the cube from Reality Composer Pro
            Task {
                do {
                    let loadedCube = try await Entity(named: "cube1", in: realityKitContentBundle)
                    
                    // Position the cube at eye level in front of the user
                    loadedCube.position = SIMD3<Float>(2.5, 0.7, -1.8) // Eye level (1.6m high), 1.5m in front
                    
                    // Enable input handling for fallback tap
                    loadedCube.components.set(InputTargetComponent())
                    loadedCube.components.set(CollisionComponent(shapes: [.generateBox(width: 0.2, height: 0.2, depth: 0.2)]))
                    
                    // Add the tapped component for game management
                    loadedCube.components.set(TappedComponent2())
                    
                    // Setup speech manager callback
                    speechManager.onCubeDetected = { [weak loadedCube] in
                        guard let cube = loadedCube else { return }
                        handleSuccess(for: cube, method: "voice")
                    }
                    
                    // Start the game timer
                    await MainActor.run {
                        cubeEntity = loadedCube
                        startGameLoop(for: loadedCube)
                    }
                    
                    rootEntity.addChild(loadedCube)
                } catch {
                    print("Failed to load cube1: \(error)")
                }
            }
            
            content.add(rootEntity)
            rootEntity.addChild(videoEntity)
            
        } update: { content, attachments in
            // Handle attachment visibility based on game state
            guard let cube = cubeEntity else { return }
            guard let component = cube.components[TappedComponent2.self] else { return }
            
            // Update cube visibility
            cube.isEnabled = component.cubeVisible
            
            // Handle main UI window - attach to root entity instead of content
            if let gameUIEntity = attachments.entity(for: "gameUI") {
                if component.gameState == .active || component.gameState == .showingResult {
                    gameUIEntity.components.set(BillboardComponent())
                    rootEntity.addChild(gameUIEntity)
                    // Fixed position at x=0, y=2, z=-1 (above and slightly forward)
                    gameUIEntity.setPosition(SIMD3<Float>(0, 2.0, -1.0), relativeTo: rootEntity)
                    print("DEBUG: UI added to rootEntity at (0, 2, -1)")
                } else {
                    rootEntity.removeChild(gameUIEntity)
                    print("DEBUG: UI removed from rootEntity")
                }
            } else {
                print("DEBUG: gameUIEntity not found")
            }
            
        } attachments: {
            // Combined Game UI window - positioned at fixed location above user
            Attachment(id: "gameUI") {
                if let cube = cubeEntity,
                   let component = cube.components[TappedComponent2.self] {
                    
                    VStack(spacing: 30) { // Increased spacing
                        if component.gameState == .active {
                            // Question and countdown during active phase
                            VStack(spacing: 25) { // Increased spacing
                                Text("What color is the car?")
                                    .font(.largeTitle) // Made bigger
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                
                                Text("Say: 'Blue'")
                                    .font(.title) // Made bigger
                                    .foregroundColor(.yellow)
                                    .fontWeight(.semibold)
                                
                                Text("\(component.countdownTime)")
                                    .font(.system(size: 80, weight: .heavy)) // Much bigger countdown
                                    .foregroundColor(.red)
                                    .fontWeight(.heavy)
                            }
                        }
                        else if component.gameState == .showingResult {
                            // Result with reaction time
                            VStack(spacing: 20) {
                                if component.wasTapped {
                                    Text("Congratulations!")
                                        .font(.largeTitle) // Made bigger
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                    
                                    if let reactionTime = component.reactionTime {
                                        Text("Reaction time: \(String(format: "%.2f", reactionTime)) seconds")
                                            .font(.title) // Made bigger
                                            .foregroundColor(.white)
                                            .fontWeight(.medium)
                                    }
                                } else {
                                    Text("You missed it!")
                                        .font(.largeTitle) // Made bigger
                                        .foregroundColor(.red)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        else {
                            // Fallback for debugging
                            Text("Game State: \(String(describing: component.gameState))")
                                .font(.title) // Made bigger
                                .foregroundColor(.white)
                        }
                    }
                    .padding(50) // Increased padding for bigger overall size
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(25) // Bigger corner radius
                    .glassBackgroundEffect()
                    .tag("gameUI")
                } else {
                    // Fallback UI when cube not loaded
                    Text("Loading...")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(30)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .tag("gameUI")
                }
            }
        }
        .gesture(
            // Fallback tap gesture for testing
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    if let component = value.entity.components[TappedComponent2.self],
                       component.gameState == .active && !component.wasTapped {
                        handleSuccess(for: value.entity, method: "tap")
                    }
                }
        )
    }
    
    private func handleSuccess(for entity: Entity, method: String) {
        guard let component = entity.components[TappedComponent2.self],
              component.gameState == .active && !component.wasTapped else { return }
        
        // Calculate reaction time
        let endTime = Date()
        if let startTime = component.reactionStartTime {
            component.reactionTime = endTime.timeIntervalSince(startTime)
        }
        
        // Update game state
        component.wasTapped = true
        component.gameState = .showingResult
        
        print("Success via \(method)! Reaction time: \(component.reactionTime ?? 0) seconds")
    }
    
    private func startGameLoop(for cube: Entity) {
        Task {
            while true {
                guard let component = cube.components[TappedComponent2.self] else { return }
                
                // Wait phase (20 seconds - change the number below to adjust wait time)
                component.gameState = .waiting
                component.cubeVisible = false
                component.wasTapped = false
                component.resultMessage = ""
                component.reactionStartTime = nil
                component.reactionTime = nil
                
                // Stop any listening from previous round
                await speechManager.stopListening()
                print("Game: Waiting phase (20s)")
                
                try await Task.sleep(nanoseconds: 20_000_000_000) // 20 seconds - CHANGE THIS TO ADJUST WAIT TIME
                
                // Active phase (30 seconds with countdown - change both numbers below to adjust challenge duration)
                component.gameState = .active
                component.cubeVisible = true
                component.countdownTime = 30  // CHANGE THIS TO ADJUST COUNTDOWN START NUMBER
                component.reactionStartTime = Date() // Start reaction timer
                
                // Start voice recognition
                await speechManager.startListening()
                print("Game: Active phase (30s) - Listening for 'blue'")
                
                // Countdown loop - CHANGE THE "30" BELOW TO MATCH THE countdownTime ABOVE
                for countdown in stride(from: 30, through: 1, by: -1) {
                    guard !component.wasTapped else { break }
                    component.countdownTime = countdown
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
                
                // Stop listening after countdown
                await speechManager.stopListening()
                
                // Check if time ran out without success
                if !component.wasTapped {
                    component.gameState = .showingResult
                    component.resultMessage = "You missed it!"
                    print("Game: Time's up - Missed!")
                }
                
                // Result phase (10 seconds) - cube stays visible
                print("Game: Showing result (10s)")
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                
                // Loop continues automatically
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    VoiceImmersiveView()
        .environment(AppModel())
}
