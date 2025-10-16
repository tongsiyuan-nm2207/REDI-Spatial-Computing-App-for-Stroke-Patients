//
//  DoctorView.swift
//  simulation
//
//  Created by Interactive 3D Design on 24/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DoctorView: View {
    var body: some View {
        HStack(spacing: 20) {
          //  OrnamentsView1().frame(width: 100, height: 400)
            
            NavigationStack {
                VStack(spacing: 0) {
                    
                    Text("Lina's Results")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                    
                    Text("24 Sep 2025, 10:07am")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 50)
                        .padding(.top, 5)
                    
                    
                    // Main content area with two columns
                    HStack(alignment: .top, spacing: 80) {
                        // Left column - Obstacles detected
                        VStack {
                            Text("Obstacles detected")
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                                .padding(.bottom, 20)
                            
                            ObstaclePieChart()
                                .frame(width: 200, height: 200)
                        }
                        
                        // Right column - Reaction time and Egocentric neglect
                        VStack(alignment: .center, spacing: 35) {
                            // Reaction time section
                            VStack(alignment: .center, spacing: 15) {
                                Text("Reaction time")
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                
                                Text("06:03s")
                                    .font(.system(size: 20))
                                    .fontWeight(.regular)
                                
                                CustomProgressBar(
                                    progress: 0.55,
                                    greenMarkerPosition: 0.20,
                                    whiteMarkerPosition: 0.35,
                                    redMarkerPosition: 0.65
                                )
                                .frame(width: 400, height: 30)
                            
                                
                            }
                            
                            // Egocentric neglect section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Egocentric neglect")
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                
                                HStack (spacing: 15) {
                                    Image(systemName: "eye.slash")
                                        .font(.system(size: 72))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("18%")
                                            .font(.system(size: 20))
                                            .fontWeight(.semibold)
                                        Text("Left")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 50)
                    
                    // Speak to Begin button
                    Button {
                        // Action for speak to begin
                    } label: {
                        Text("Say 'Continue'")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 12)
                            .cornerRadius(20)
                    }
                    .padding(.top, 70)
                    
                }
            }
        }
    }
}

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}
