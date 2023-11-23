// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var cameraManager = CameraManager()

    var body: some View {
        VStack {
            CameraView(cameraManager: cameraManager)
            Button("Snap") {
                cameraManager.captureImage { buffer in
                    // Handle captured image (pixelBuffer)
                    print(buffer)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Circle())
        }
    }
}
