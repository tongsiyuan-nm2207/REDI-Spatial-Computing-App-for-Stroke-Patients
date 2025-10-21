//
//  ContentView6.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 20/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView6: View {
    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("SIX Hello, world!")
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView6()
}
