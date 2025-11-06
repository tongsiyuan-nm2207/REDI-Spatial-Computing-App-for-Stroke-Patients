//
//  REDIApp.swift
//  REDI
//
//  Created by Interactive 3D Design on 23/10/25.
//

import SwiftUI

@main
struct REDIApp: App {

    @State private var appModel = AppModel()
    @State private var assessmentState = AssessmentState()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environment(appModel)
                .environment(assessmentState)
        }.windowStyle(.plain)

        // Combined Hand Tracking + Immersive Space
        ImmersiveSpace(id: "HandImmersiveSpace") {
            ZStack {
                // Your immersive 180° video view (bottom layer)
                HandImmersiveView()
                    .environment(appModel)
            }
            .onAppear {
                appModel.immersiveSpaceState = .open
            }
            .onDisappear {
                appModel.immersiveSpaceState = .closed
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // Voice immersive space with assessment
        ImmersiveSpace(id: "VoiceImmersiveSpace") {
            VoiceImmersiveView()
                .environment(appModel)
                .environment(assessmentState)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
