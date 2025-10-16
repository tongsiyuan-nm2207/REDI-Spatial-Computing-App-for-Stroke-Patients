//
//  DetailView.swift
//  simulation
//
//  Created by Interactive 3D Design on 10/9/25.
//

//Results view

import SwiftUI
import RealityKit
import RealityKitContent

struct DetailView: View {
    
    @State private var showingPreviewScenario = false
    
    var body: some View {
        
        VStack{
            
            VStack(spacing: 20) {

//start of picture button
                Button {
                    print("Button pressed")
                    showingPreviewScenario = true
                } label: {
                    ZStack {
                        Image("maxwellCentre")
                            .resizable()
                            .aspectRatio(contentMode:.fill)
                            .frame(maxWidth: 850)
                        //Text("Button Text")
                    }
                }
//end of picture button
                
                }
            }
            .padding()
        .fullScreenCover(isPresented: $showingPreviewScenario) {
            PreviewScenario()
        }

            
            Button {
                print("Button pressed")
            } label: {
                ZStack {
                    Image("maxwellCentre")
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(maxWidth: 850)
                    //Text("Button Text")
                }
            }
            

            Button{} label:{
                Label(
                    "back", systemImage:"chevron.backward.circle").labelStyle(.iconOnly)
            }
            
            Text("Hello, DetailView!")
        }
       //    .padding(10)
       // .glassBackgroundEffect()
    }
//}

 func goHome() {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    windowScene?.windows.forEach { window in
        window.rootViewController = UIHostingController(rootView: DetailView())
        window.makeKeyAndVisible()
    }
}

/*#Preview {
 DetailView()
 }
 */

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
