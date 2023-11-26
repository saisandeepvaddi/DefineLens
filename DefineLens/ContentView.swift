//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)

            if let previewLayer = cameraManager.previewLayer {
                BoundingBoxesView(observations: cameraManager.textObservations, previewLayer: previewLayer)
                    .edgesIgnoringSafeArea(.all)
            }

            // Crosshair in the center
            Image(systemName: "cross.circle.fill")
                .foregroundColor(.red)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

            VStack {
                Spacer()
                Button("Snap") {
                    snapWord()
                }
            }
        }
    }

    func snapWord() {
        // Logic to get the word under the crosshair and print it
    }
}

#Preview {
    ContentView()
}
