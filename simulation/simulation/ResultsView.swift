//
//  ResultsView.swift
//  simulation
//
//  Created by Interactive 3D Design on 24/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ResultsView: View {
    
    @State private var navigate6 = false
    
    
    var body: some View {
        
        
        HStack(spacing: 20) {
            OrnamentsView1().frame(width: 100, height: 400)
            
            NavigationStack {
                VStack(spacing: 0) {
                    
                    Text("Your Results")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
                    Text("24 Sep 2025, 10:07am")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 50)
                        .padding(.bottom, 40)
                    
                    /*
                    Text("Overall Assessment Score")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                     */
                    
                    // Circular Progress Ring
                    ZStack {
                        // Background circle (remaining portion)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 12)
                            .frame(width: 180, height: 180)
                        
                        // Progress circle (completed portion)
                        Circle()
                            .trim(from: 0, to: 0.8) // 8/10 = 0.8
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-90))
                        
                        // Score text
                        VStack(spacing: 4) {
                            Text("You scored")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("8/10")
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Text("Good job! Keep it up.")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 40)
                    
                    Button {
                        // Action for speak to continue
                    } label: {
                        Text("Say 'Continue'")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 12)
                    }
                    .background(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(25)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 40)
                
                //end of button
                
                NavigationStack{
                    Button {
                        navigate6 = true
                        // Action for speak to continue
                    } label: {
                        Text("Switch to Doctor View")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 12)
                    }
                    .background(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(25)
                    .padding(.bottom, 30)
                    .opacity(0.1)
                    
                    //end of button
                }                .navigationDestination(isPresented: $navigate6){
                    DoctorView()
                }
                
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            )
            .padding(.vertical, 20)
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
