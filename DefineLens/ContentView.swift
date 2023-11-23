// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            CameraView(cameraManager: cameraManager)
            CrosshairView()
            VStack {
                Spacer()
                Button("Snap") {
                    cameraManager.captureImage { buffer in
                        print("Captured")
                        guard let buffer = buffer else {
                            print("Invalid buffer")
                            return
                        }
                        if let image = cameraManager.convertToUIImage(pixelBuffer: buffer) {
                            recognizeTextAndHighlight(from: image) { recognizedText in
                                print("Recognized Text: \(recognizedText)")
                            }
                        }
                        // Handle captured image (pixelBuffer)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            }
        }
    }
}
