//
//  OrnamentsView.swift
//  simulation
//
//  Created by Interactive 3D Design on 28/9/25.
//

//
//  OrnamentsView1.swift
//  simulation
//
//  Created by Seidl Kim on 16/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent



struct OrnamentsView: View {
    var body: some View {
        TabView {
            InformationView()
                .tabItem {
                    Label("Information", systemImage: "info")
                }
            
            PatientDashboard()
                .tabItem {
                    Label("Patient Dashboard", systemImage: "person.crop.circle")
                }
            
            HelpView()
                .tabItem {
                    Label("Help",systemImage: "questionmark")
                }
        }
    }
}
#Preview {
    OrnamentsView()
}

            
            
            
//            VStack(spacing:40){
//
//                VStack(spacing:15) {
//                    Button{} label: {
//                        Label(
//                            "info", systemImage: "info")
//                        .labelStyle(.iconOnly)}
//
//
//                    Button {
//                        print("Button pressed")
//                        showingPatientDashboard = true}
//                    label: {
//                        Label(
//                            "profilepicture", systemImage: "person.crop.circle")
//                        .labelStyle(.iconOnly)}
//
//
//                    Button{} label: {
//                        Label(
//                            "help", systemImage: "questionmark")
//                        .labelStyle(.iconOnly)}
//
//
//                }.padding(12)
//                    .background{
//                        RoundedRectangle(cornerRadius:12).foregroundStyle(.bar)
//                            .opacity(0.25)
//                            .brightness(-0.4)
//                    }.glassBackgroundEffect()
//            }
//        }
//    }
//}
//#Preview {
//    OrnamentsView1()
//
//}
