//
//  CaptureButton.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/27/23.
//

import SwiftUI

struct CaptureButton: View {
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var appState: AppState
    @State private var capturedWord: String?
    @State private var navigateToDefinition = false
    var body: some View {
        Button(action: {
            cameraManager.capturePhoto { word in
                print("Captured Word: \(word ?? "No word")")
                guard let word = word else {
                    logger.error("No word captured")
                    return
                }
                self.capturedWord = word
                self.navigateToDefinition = true
            }
        }) {
            Text(cameraManager.wordUnderCrosshair ?? "Check")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.title)
                .cornerRadius(20)
        }.padding()
//        NavigationLink(destination: DefinitionView(word: capturedWord), isActive: self.$navigateToDefinition) {
//            EmptyView()
//        }
    }
}
