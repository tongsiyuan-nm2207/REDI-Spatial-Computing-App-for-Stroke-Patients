//
//  AssessmentResultsView.swift
//  Week 10 Code
//
//  Created by Interactive 3D Design on 19/10/25.
//

import SwiftUI

struct AssessmentResultsView: View {
    let marks: Int
    let averageReactionTime: Double
    @State private var showingAirDropSheet = false
    @State private var showingSuccessView = false
    
    // ✅ Environments for navigation and state management
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(AssessmentState.self) private var assessmentState
    
    // Format reaction time as seconds with 2 decimal places
    var formattedReactionTime: String {
        return String(format: "%.2fs", averageReactionTime)
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 50) {
                // Title with GIF overlay
                Text("Lina Tay's Assessment Results")
                    .font(.custom("Nohemi-Medium", size: 32))
                    .foregroundStyle(Color(hex: "fff16c"))
                    .overlay(alignment: .topTrailing) {
                        // ADJUST GIF POSITION HERE:
                        // - Change 'x' value to move left (negative) or right (positive)
                        // - Change 'y' value to move up (negative) or down (positive)
                        // - Change 'width' and 'height' to resize the GIF
                        GIFPlayerView("results_happy", playOnce: true)
                            .frame(width: 400, height: 300)
                            .offset(x: 250, y: -100)
                    }
                
                // Metrics Cards
                HStack(spacing: 50) {
                    MetricCard(
                        value: formattedReactionTime,
                        label: "Average reaction time"
                    )
                    
                    MetricCard(
                        value: "\(marks)/4",
                        label: "Obstacles completed"
                    )
                }
                .padding(.horizontal, 280)
                
                // Action Buttons
                HStack(spacing: 16) {
                    ActionButton(
                        icon: "checkmark.circle",
                        label: "Finish",
                        isPrimary: false,
                        action: {
                            // ✅ Reset assessment state
                            assessmentState.reset()
                            print("🔄 Assessment state reset")
                            
                            // ✅ Close completion window
                            dismissWindow(id: "CompletionWindow")
                            print("🚪 Completion window dismissed")
                            
                            // ✅ Open welcome window (fresh start)
                            openWindow(id: "welcome")
                            print("🏠 Welcome window opened - Test ready for next user")
                        }
                    )
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        label: "Airdrop PDF",
                        isPrimary: false,
                        action: {
                            showingAirDropSheet = true
                        }
                    )
                }
                .padding(.top, 20)
            }
            .transition(.opacity)
            
            // AirDrop Sheet Overlay
            if showingAirDropSheet && !showingSuccessView {
                AirDropSheet(
                    isPresented: $showingAirDropSheet,
                    showingSuccessView: $showingSuccessView
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            
            // Success View Overlay
            if showingSuccessView {
                AirDropSuccessView(isPresented: $showingSuccessView)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingAirDropSheet)
        .animation(.easeInOut(duration: 0.3), value: showingSuccessView)
    }
}

struct AirDropSheet: View {
    @Binding var isPresented: Bool
    @Binding var showingSuccessView: Bool
    @State private var selectedDevice: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 4, height: 4)
                }
                
                Spacer()
                
                Text("Send Copy with AirDrop")
                    .font(.custom("Nohemi-Medium", size: 24))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Invisible spacer to balance the close button
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // Devices Section
            VStack(alignment: .leading, spacing: 24) {
                Text("Devices")
                    .font(.custom("Nohemi-Bold", size: 20))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 32)
                
                // Device List - Horizontal ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        DeviceColumn(
                            deviceName: "Kevin's iPhone",
                            deviceIcon: "iphone.gen3",
                            isSelected: selectedDevice == "Kevin's iPhone",
                            action: {
                                selectedDevice = "Kevin's iPhone"
                                // Simulate sending
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isPresented = false
                                        showingSuccessView = true
                                    }
                                }
                            }
                        )
                        
                        DeviceColumn(
                            deviceName: "Maya's MacBook",
                            deviceIcon: "laptopcomputer",
                            isSelected: selectedDevice == "Maya's MacBook",
                            action: {
                                selectedDevice = "Maya's MacBook"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isPresented = false
                                        showingSuccessView = true
                                    }
                                }
                            }
                        )
                        
                        DeviceColumn(
                            deviceName: "Sarah's iPad",
                            deviceIcon: "ipad",
                            isSelected: selectedDevice == "Sarah's iPad",
                            action: {
                                selectedDevice = "Sarah's iPad"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isPresented = false
                                        showingSuccessView = true
                                    }
                                }
                            }
                        )
                        
                        DeviceColumn(
                            deviceName: "David's Macbook",
                            deviceIcon: "laptopcomputer",
                            isSelected: selectedDevice == "David's Apple Watch",
                            action: {
                                selectedDevice = "David's Apple Watch"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isPresented = false
                                        showingSuccessView = true
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 32)
                }
            }
            
            Spacer()
        }
        .frame(width: 668, height: 360)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}

struct DeviceColumn: View {
    let deviceName: String
    let deviceIcon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Device Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if isSelected {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: deviceIcon)
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(deviceName)
                    .font(.custom("Nohemi-Medium", size: 16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 100, height: 40)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .white.opacity(0.15) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

struct MetricCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(value)
                .font(.custom("Nohemi-Bold", size: 56))
                .foregroundStyle(Color(hex: "fff16c"))
            
            Text(label)
                .font(.custom("Nohemi-Regular", size: 18))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(label)
                    .font(.custom("Nohemi-Medium", size: 20))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 14)
            .glassBackgroundEffect()
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AssessmentResultsView(marks: 2, averageReactionTime: 7.59)
        .environment(AssessmentState())
}
