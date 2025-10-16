import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct VideoPlayerView: View {
  // Create a URL for the video file in your app bundle
  let videoURL: URL? = Bundle.main.url(forResource: "RoadCrossingTrimmed", withExtension: "mp4")

  var body: some View {
    VStack {
      if let url = videoURL {
        VideoPlayer(player: AVPlayer(url: url))
      } else {
        Text("Video not found")
      }
    }
  }
}

struct HawkerCentre: View {
    @State private var player: AVPlayer? // Declare the AVPlayer
    @State private var showingPreviewScenario = false
    @State private var navigate = false
    
    var body: some View {
        
        NavigationStack{
            VStack(spacing: 10) {
                
                // Back button at the top
                HStack {
                    
                    /*
                    Button(action: {
                        showingPreviewScenario = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                     */
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack (spacing:10)
                {
                    Text("Road Crossing")
                        .font(.largeTitle)
                    
                    Text("Test your object identification skills and spatial awareness.")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .padding(.bottom,20)
                    
                }
                .padding(.horizontal,20)
                .multilineTextAlignment(.center)
                
                VideoPlayerView()
                    .frame(width: 800, height: 450)
                
            }
            .padding()
            .fullScreenCover(isPresented: $showingPreviewScenario) {
                PreviewScenario()
            }
        }
    }
}
    
#Preview {
    HawkerCentre()
}
