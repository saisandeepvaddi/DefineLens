//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cameraManager = CameraManager()
    @StateObject var appState = AppState()
    @State var clickedWord: String = ""
    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)

            if let previewLayer = cameraManager.previewLayer {
                BoundingBoxesView(observations: cameraManager.textObservations, previewLayer: previewLayer, onWordChange: { newWord in
                    appState.word = newWord
                })
                .edgesIgnoringSafeArea(.all)
                .environmentObject(appState)
            }

            Image(systemName: "circle")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            VStack {
                Spacer()
                Button("Snap") {
                    snapWord()
                }
            }
        }
    }

    func snapWord() {
        print("Word: \(appState.word)")

        // Logic to get the word under the crosshair and print it
    }
}

// #Preview {
//    ContentView()
// }
