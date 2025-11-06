//
//  GIFPlayerView.swift
//  REDI
//
//  Created by Interactive 3D Design on 2/11/25.
//

import SwiftUI
import WebKit
import ImageIO

/// A SwiftUI view that displays animated GIF images
/// This implementation uses WKWebView for reliable GIF playback on visionOS
/// Supports playing once with completion callback
struct GIFPlayerView: UIViewRepresentable {
    let gifName: String
    let playOnce: Bool
    let onComplete: (() -> Void)?
    
    init(_ gifName: String, playOnce: Bool = false, onComplete: (() -> Void)? = nil) {
        self.gifName = gifName
        self.playOnce = playOnce
        self.onComplete = onComplete
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Load the GIF from bundle
        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            
            // If we need to play once, calculate the duration and set up completion
            if playOnce {
                let duration = calculateGIFDuration(from: data)
                
                // Load the GIF with JavaScript that will freeze on the last frame
                let htmlString = """
                <html>
                <head>
                    <style>
                        body {
                            margin: 0;
                            padding: 0;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            height: 100vh;
                            background: transparent;
                        }
                        img {
                            max-width: 100%;
                            max-height: 100%;
                            object-fit: contain;
                        }
                    </style>
                    <script>
                        // Freeze the GIF on the last frame after one loop
                        setTimeout(function() {
                            var img = document.getElementById('gif');
                            // Create a canvas to capture the last frame
                            var canvas = document.createElement('canvas');
                            canvas.width = img.naturalWidth;
                            canvas.height = img.naturalHeight;
                            var ctx = canvas.getContext('2d');
                            ctx.drawImage(img, 0, 0);
                            // Replace the GIF with the static image
                            img.src = canvas.toDataURL();
                        }, \(Int(duration * 1000)));
                    </script>
                </head>
                <body>
                    <img id="gif" src="data:image/gif;base64,\(data.base64EncodedString())" crossorigin="anonymous" />
                </body>
                </html>
                """
                
                webView.loadHTMLString(htmlString, baseURL: nil)
                
                // Schedule completion callback
                if let onComplete = onComplete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onComplete()
                    }
                }
            } else {
                // Normal looping playback
                webView.load(
                    data,
                    mimeType: "image/gif",
                    characterEncodingName: "UTF-8",
                    baseURL: url.deletingLastPathComponent()
                )
            }
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Reload if needed when the view updates
    }
    
    /// Calculate the total duration of a GIF animation
    private func calculateGIFDuration(from data: Data) -> Double {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return 2.0 // Default fallback duration
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var totalDuration = 0.0
        
        for i in 0..<frameCount {
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                  let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
                continue
            }
            
            // Get frame delay
            var frameDuration = 0.1 // Default frame duration
            if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double, delayTime > 0 {
                frameDuration = delayTime
            } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double, delayTime > 0 {
                frameDuration = delayTime
            }
            
            totalDuration += frameDuration
        }
        
        return totalDuration > 0 ? totalDuration : 2.0
    }
}

#Preview {
    VStack {
        GIFPlayerView("your_animation", playOnce: true, onComplete: {
            print("GIF finished playing!")
        })
            .frame(width: 500, height: 300)
            .background(Color.black.opacity(0.3))
    }
}
