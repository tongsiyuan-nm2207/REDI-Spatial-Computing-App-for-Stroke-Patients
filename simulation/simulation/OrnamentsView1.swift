//
//  OrnamentsView1.swift
//  simulation
//
//  Created by Seidl Kim on 16/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct OrnamentsView1: View {
    var body: some View {
        TabView {
            
            VStack(spacing:40){
                
                VStack(spacing:15) {
                    Button{} label: {
                        Label(
                            "info", systemImage: "info")
                        .labelStyle(.iconOnly)}
                    
                    
                    Button{} label: {
                        Label(
                            "settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)}
                    
                    
                    Button{} label: {
                        Label(
                            "help", systemImage: "questionmark")
                        .labelStyle(.iconOnly)}
                    
                    
                }.padding(12)
                    .background{
                        RoundedRectangle(cornerRadius:12).foregroundStyle(.bar)
                            .opacity(0.25)
                            .brightness(-0.4)
                    }.glassBackgroundEffect()
            }
        }
    }
}
#Preview {
    OrnamentsView1()
    
}
