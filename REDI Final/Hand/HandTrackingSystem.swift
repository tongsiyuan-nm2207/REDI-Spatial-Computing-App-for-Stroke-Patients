//
//  HandTrackingSystem.swift
//  REDI
//
//  Created by Interactive 3D Design on 25/10/25.
//
/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system that updates entities that have hand-tracking components.
*/
/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A system that updates entities that have hand-tracking components.
*/
import RealityKit
import ARKit
internal import UIKit


/// A system that provides hand-tracking capabilities.
struct HandTrackingSystem: System {
    /// The active ARKit session.
    static var arSession = ARKitSession()

    /// The provider instance for hand-tracking.
    static let handTracking = HandTrackingProvider()

    /// The most recent anchor that the provider detects on the left hand.
    static var latestLeftHand: HandAnchor?

    /// The most recent anchor that the provider detects on the right hand.
    static var latestRightHand: HandAnchor?

    init(scene: RealityKit.Scene) {
        Task { await Self.runSession() }
    }
 
    @MainActor
    static func runSession() async {
        do {
            // Attempt to run the ARKit session with the hand-tracking provider.
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            print("The app has encountered an error while running providers: \(error.localizedDescription)")
        } catch let error {
            print("The app has encountered an unexpected error: \(error.localizedDescription)")
        }

        // Start to collect each hand-tracking anchor.
        for await anchorUpdate in handTracking.anchorUpdates {
            // Check whether the anchor is on the left or right hand.
            switch anchorUpdate.anchor.chirality {
            case .left:
                self.latestLeftHand = anchorUpdate.anchor
            case .right:
                self.latestRightHand = anchorUpdate.anchor
            }
        }
    }
    
    /// The query this system uses to find all entities with the hand-tracking component.
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    /// Performs any necessary updates to the entities with the hand-tracking component.
    /// - Parameter context: The context for the system to update.
    func update(context: SceneUpdateContext) {
        let handEntities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in handEntities {
            guard var handComponent = entity.components[HandTrackingComponent.self] else { continue }

            // Set up the finger joint entities if you haven't already.
            if handComponent.fingers.isEmpty {
                self.addJoints(to: entity, handComponent: &handComponent)
            }

            // Get the hand anchor for the component, depending on its chirality.
            guard let handAnchor: HandAnchor = switch handComponent.chirality {
                case .left: Self.latestLeftHand
                case .right: Self.latestRightHand
                default: nil
            } else { continue }

            // Iterate through all of the anchors on the hand skeleton.
            if let handSkeleton = handAnchor.handSkeleton {
                var totalHeight: Float = 0.0
                var fingerJointCount: Float = 0.0
                
                for (jointName, jointEntity) in handComponent.fingers {
                    /// The current transform of the person's hand joint.
                    let anchorFromJointTransform = handSkeleton.joint(jointName).anchorFromJointTransform

                    // Update the joint entity to match the transform of the person's hand joint.
                    let worldTransform = handAnchor.originFromAnchorTransform * anchorFromJointTransform
                    jointEntity.setTransformMatrix(worldTransform, relativeTo: nil)
                    
                    // Calculate height (y-coordinate) for finger joints only
                    if isFingerJoint(jointName) {
                        let position = worldTransform.columns.3
                        totalHeight += position.y
                        fingerJointCount += 1.0
                    }
                }
                
                // Calculate average hand height
                if fingerJointCount > 0 {
                    handComponent.handHeight = totalHeight / fingerJointCount
                    
                    // Check if hand is lifted above standard height
                    handComponent.handLifted = handComponent.handHeight > handComponent.standard
                    
                    // Update the shared state manager
                    Task { @MainActor in
                        if handComponent.chirality == .left {
                            HandStateManager.shared.updateLeftHand(
                                height: handComponent.handHeight,
                                lifted: handComponent.handLifted
                            )
                        } else {
                            HandStateManager.shared.updateRightHand(
                                height: handComponent.handHeight,
                                lifted: handComponent.handLifted
                            )
                        }
                    }
                }
                
                // Apply the updated hand component back to the entity
                entity.components.set(handComponent)
            }
        }
    }
    
    /// Helper function to determine if a joint is a finger joint (excludes wrist and forearm)
    /// - Parameter jointName: The name of the joint to check
    /// - Returns: True if the joint is part of a finger
    private func isFingerJoint(_ jointName: HandSkeleton.JointName) -> Bool {
        switch jointName {
        case .forearmWrist, .forearmArm:
            return false
        default:
            return true
        }
    }
    
    /// Performs any necessary setup to the entities with the hand-tracking component.
    /// - Parameters:
    ///   - entity: The entity to perform setup on.
    ///   - handComponent: The hand-tracking component to update.
    func addJoints(to handEntity: Entity, handComponent: inout HandTrackingComponent) {
        /// The size of the sphere mesh.
        let radius: Float = 0.005

        /// The material to apply to the sphere entity.
        let material = SimpleMaterial(color: .white.withAlphaComponent(0), isMetallic: false)

        /// The sphere entity that represents a joint in a hand.
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )

        // For each joint, create a sphere and attach it to the fingers.
        for bone in Hand.joints {
            // Add a duplication of the sphere entity to the hand entity.
            let newJoint = sphereEntity.clone(recursive: false)
            handEntity.addChild(newJoint)

            // Attach the sphere to the finger.
            handComponent.fingers[bone.0] = newJoint
        }

        // Apply the updated hand component back to the hand entity.
        handEntity.components.set(handComponent)
    }
}

