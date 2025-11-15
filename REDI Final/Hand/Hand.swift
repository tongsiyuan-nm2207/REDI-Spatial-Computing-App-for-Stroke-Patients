/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A structure containing all entities attached to hand-tracking anchors.
*/

import ARKit.hand_skeleton

/// A structure that contains data for finger joints.
struct Hand {
    /// The collection of joints in a hand.
    static let joints: [(HandSkeleton.JointName, Finger, Bone)] = [
        (.thumbTip, .thumb, .tip),

        // Define the index-finger bones.
        (.indexFingerTip, .index, .tip),

        // Define the middle-finger bones.
        (.middleFingerTip, .middle, .tip),

        // Define the ring-finger bones.
        (.ringFingerTip, .ring, .tip),

        // Define the little-finger bones.
        (.littleFingerTip, .little, .tip),

        // Define wrist and arm bones.
        (.forearmWrist, .forearm, .wrist),
        (.forearmArm, .forearm, .arm)
    ]
}


enum Finger: Int, CaseIterable {
    case forearm
    case thumb
    case index
    case middle
    case ring
    case little
}

enum Bone: Int, CaseIterable {
    case arm
    case wrist
    case tip
}

