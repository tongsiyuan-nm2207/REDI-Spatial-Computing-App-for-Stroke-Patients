//
//  PatientDashboard.swift
//  simulation
//
//  Created by Interactive 3D Design on 28/9/25.
//


//
//  PatientDashboard.swift
//  simulation
//
//  Created by Seidl Kim on 26/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PatientDashboard: View {
    @State private var navigate = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Profile circle
                    Circle()
                        .fill(Color.white)
                        //.frame(width: 50, height: 50)
                        
                        .overlay(
                            Image("profilePic")
                                .resizable()
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lina's dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("32 | Female")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                    .padding (.vertical,10)
                    
                    Spacer()
                    
                    Button("Edit") {
                        // Edit action
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
               
                
                // Neglect type and Method sections
                HStack(spacing: 16) {
                    SettingCard(title: "Neglect type", subtitle: "Egocentric")
                    SettingCard(title: "Method", subtitle: "Voice activation")
                }
            }
            .padding(24)
            .padding(.bottom,10)
            
            // Latest Status and Results section
            HStack(alignment: .top, spacing: 16) {
                // Latest Status
                VStack(alignment: .leading, spacing: 20) {
                    Text("Latest Status")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        StatusRow(date: "Jul 5, 2025",
                                  title: "Visit at SGH",
                                  subtitle: "Physlth Doctor Lin")
                        
                        StatusRow(date: "May 22, 2025",
                                  title: "Physiotherapy at NUH",
                                  subtitle: "Check-up with Doctor Lin")
                        
                        StatusRow(date: "Mar 1, 2025",
                                  title: "Visit at SGH",
                                  subtitle: "Check-up with Doctor Lin")
                    }
                }
                
                // Results
                VStack(alignment: .leading, spacing: 20) {
                    Text("Results")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        ResultCard(title: "Spatial Awareness (Visual)",
                                   leftValue: "30%",
                                   rightValue: "100%")
                        
                        
                        ResultCard(title: "Spatial Awareness (Audio)",
                                   leftValue: "30%",
                                   rightValue: "100%")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .glassBackgroundEffect()
        .cornerRadius(30)
        .padding(200)
    }
      
}

struct SettingCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
}

struct StatusRow: View {
    let date: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 30) {
                Text(date)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

struct ResultCard: View {
    let title: String
    let leftValue: String
    let rightValue: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Left: \(leftValue), Right:\(rightValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
    
}

#Preview {
    PatientDashboard()
}
