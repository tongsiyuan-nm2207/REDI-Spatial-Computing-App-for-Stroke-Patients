//
//  PreviewScenario.swift
//  simulation
//
//  Created by Interactive 3D Design on 10/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PreviewScenario: View {
    @State private var showingHawkerCentre = false
    @State private var showingGalleryView = false
    @State private var showingContentView = false
    @State private var navigate = false
    
    var body: some View {
        
        NavigationStack{
            VStack(spacing: 10){
                
                // Back button at the top
                HStack {
                   
                    
                    Button(action: {
                        showingGalleryView = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(spacing: 10){
                    Text("Road Crossing Journey")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Cross the road and look out for vehicles.")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .padding(.bottom,10)
                }
                .padding(.horizontal,20)
                .multilineTextAlignment(.center)
                
                VStack(spacing:20){
                    Image("RoadCrossingPreview")
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(maxWidth: 500)
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
        
                    Button {
                        navigate = true
                    } label: {
                        Text("Show Demo")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        
                    }.buttonStyle(.plain)
                        .padding(10)
                        .padding(.horizontal,20)
                        .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(30)
                        .navigationDestination(isPresented: $navigate){
                            HawkerCentre()
                        }
                    
                    //this button below should be replaced with the button to go to the 360 video exercise
                    Button(action: goHome) {
                        HStack(alignment: .center) {
                            Text("Start Exercise")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                        }
                    }.background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                
                }
            }
            .padding()
            .cornerRadius(20)
            .padding()
            .fullScreenCover(isPresented: $showingGalleryView) {
                GalleryView()
            }
        }
    }
}

#Preview {
    PreviewScenario()
}
