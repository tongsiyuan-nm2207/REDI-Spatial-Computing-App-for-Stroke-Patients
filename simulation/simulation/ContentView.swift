import SwiftUI
import RealityKit
import RealityKitContent

enum SidebarSelection {
    case home
    case information
    case patientDashboard
    case help
}

struct ContentView: View {
    @State private var navigate3 = false
    @State private var navigate5 = false
    @State private var navigate6 = false
    @State private var navigate7 = false
    @State private var selectedView: SidebarSelection = .home
    @State private var speechManager = UISpeechManager()
    
    var body: some View {
        HStack(spacing: 20) { // Added spacing between main content and sidebar
            // Main content area with fixed width to prevent sidebar movement
            mainContentView
                .frame(maxWidth: .infinity) // Take up remaining space
            
            // Fixed sidebar with consistent positioning
            sidebarView
                .frame(width: 80) // Fixed width
        }
        .padding(.trailing, 20) // Add spacing from window edge
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedView {
        case .home:
            homeView
        case .information:
            InformationView()
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure consistent sizing
        case .patientDashboard:
            PatientDashboard()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .help:
            HelpView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
        
    
    private var homeView: some View {
        NavigationStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image("profilePic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .padding(.top, 30)
                    
                    Text("Welcome, Lina")
                        .font(.largeTitle)
                        .padding(.top, 30)
                    
                    Text("Let's begin your assessment.")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 50)
                        .padding(.top, 5)
                    
                    // Voice Control Section
                    VStack(spacing: 15) {
                        // Listening indicator
                        HStack {
                            if speechManager.isListening {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .scaleEffect(speechManager.isListening ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(), value: speechManager.isListening)
                            } else {
                                Image(systemName: "mic")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                            
                            Text(speechManager.listeningPrompt)
                                .font(.system(size: 18))
                                .foregroundColor(speechManager.isListening ? .primary : .secondary)
                        }
                        .padding(.top, 20)
                        
                        // Show error if any
                        if let error = speechManager.errorMessage {
                            Text("Error: \(error)")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Manual restart button (optional fallback)
                        if !speechManager.isListening && speechManager.errorMessage != nil {
                            Button("Try Again") {
                                speechManager.resetForNewSession()
                                startListeningForContinue()
                            }
                            .font(.system(size: 16))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, 10)
                }
                .navigationDestination(isPresented: $navigate3) {
                    GalleryView()
                }
                .onAppear {
                    startListeningForContinue()
                }
                .onDisappear {
                    speechManager.stopListening()
                }
            }
        }
    }
    
    private var sidebarView: some View {
        VStack(spacing: 20) {
            Button(action: {
                selectedView = .information
                speechManager.stopListening() // Stop listening when navigating away
            }) {
                Image(systemName: "info")
                    .font(.title2)
                    .foregroundColor(selectedView == .information ? .white : .primary)
            }
            .buttonStyle(.borderless)
            
            Button(action: {
                selectedView = .patientDashboard
                speechManager.stopListening()
            }) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(selectedView == .patientDashboard ? .white : .primary)
            }
            .buttonStyle(.borderless)
            
            Button(action: {
                selectedView = .help
                speechManager.stopListening()
            }) {
                Image(systemName: "questionmark")
                    .font(.title2)
                    .foregroundColor(selectedView == .help ? .white : .primary)
            }
            .buttonStyle(.borderless)
            
            // Home button to return to original content
            Divider()
            
            Button(action: {
                selectedView = .home
                // Restart listening when returning to home
                if selectedView != .home {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        startListeningForContinue()
                    }
                }
            }) {
                Image(systemName: "house")
                    .font(.title2)
                    .foregroundColor(selectedView == .home ? .white : .primary)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .glassBackgroundEffect()
    }
    
    // MARK: - Helper Methods
    private func startListeningForContinue() {
        speechManager.startListeningForContinue {
            // This closure is called when "continue" is detected
            navigate3 = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
