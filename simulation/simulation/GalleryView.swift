//
//  GalleryView.swift
//  simulation
//
//  Created by Interactive 3D Design on 10/9/25.
//
import SwiftUI
import RealityKit
import RealityKitContent

struct GalleryView: View {
    
    @State private var showingPreviewScenario = false
    @State private var showingContentView = false
    @State private var navigate = false
    
    var body: some View {
        
        NavigationStack{
            VStack(spacing: 10){
                
                
                /*
                // Back button at the top
                HStack {
                    Button(action: {
                        showingContentView = true
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
                */
                
                
                Text("Scenarios")
                    .font(.largeTitle)
                    //.offset(y:-30)
                
                Text("Choose one for your stroke assessment.")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .padding(.bottom,20)
                
                VStack(spacing:20){ //spacing between grid
                    HStack(spacing: -10){ //spacing between grid
                        
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("RoadCrossingPreview")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                            .buttonStyle(.plain)
                        }
                        //end of picture button
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("maxwellCentre")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                        }
                        //end of picture button
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("maxwellCentre")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                        }
                        //end of picture button
                    }
                    .navigationDestination(isPresented: $navigate){
                        GalleryView()
                    }
                    // end of first HStack
                    
                    HStack(spacing: -10){ //spacing between grid
                        
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("maxwellCentre")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                        }
                        //end of picture button
                        
                        
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("maxwellCentre")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                        }
                        //end of picture button
                        
                        
                        //start of picture button
                        Button {
                            print("Button pressed")
                            showingPreviewScenario = true
                        } label: {
                            ZStack {
                                Image("maxwellCentre")
                                    .resizable()
                                    .aspectRatio(contentMode:.fill)
                                    .frame(maxWidth: 320)
                                    .frame(maxHeight: 215)
                                    .cornerRadius(10)
                                //Text("Button Text")
                            }
                        }
                        //end of picture button
                        
                    }
                    
                    //end of the picture grid
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 10)
        //.glassBackgroundEffect()
        
        
        .fullScreenCover(isPresented: $showingPreviewScenario) {
            PreviewScenario()
        }
       
        .fullScreenCover(isPresented: $showingContentView) {
            ContentView()
        }
        .padding(.top,20)
        
    }
}

        
    #Preview {
        GalleryView()
    }

