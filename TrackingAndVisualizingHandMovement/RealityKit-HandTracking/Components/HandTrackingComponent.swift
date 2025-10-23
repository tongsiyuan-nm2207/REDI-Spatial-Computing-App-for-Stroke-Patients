/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that tracks an entity to a hand.
*/
import RealityKit
import ARKit.hand_skeleton

/// A component that tracks the hand skeleton.
/// A component that tracks the hand skeleton.
struct HandTrackingComponent: Component {
    /// The chirality for the hand this component tracks.
    let chirality: AnchoringComponent.Target.Chirality

    /// A lookup that maps each joint name to the entity that represents it.
    var fingers: [HandSkeleton.JointName: Entity] = [:]
    
    /// The average height (y-coordinate) of all finger joints
    var handHeight: Float = 0.0
    
    /// The standard height threshold in meters (5cm = 0.05m)
    let standard: Float = 0.05
    
    /// Boolean indicating if the hand is lifted above the standard height
    var handLifted: Bool = false
    
    /// Creates a new hand-tracking component.
    /// - Parameter chirality: The chirality of the hand target.
    init(chirality: AnchoringComponent.Target.Chirality) {
        self.chirality = chirality
        HandTrackingSystem.registerSystem()
    }
}
