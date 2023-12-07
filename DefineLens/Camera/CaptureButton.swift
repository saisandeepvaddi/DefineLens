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
    @State private var capturedWords: [CustomRecognizedText] = []
    @State private var navigateToDefinition = false

    var body: some View {
//        let captureCallback = appState.mode == .single ?cameraManager.captureWordInPhotoMode : cameraManager.captureWordInVideoMode

        Button(action: {
            cameraManager.captureWordInVideoMode { words in

//                print("Captured Word: \(word ?? "No word")")
                guard let words = words else {
                    logger.error("No word captured")
                    return
                }

                guard let word = words.first else {
                    print("no words")
                    return
                }

                self.capturedWords = words
                self.navigateToDefinition = true
            }
        }) {
            Text("Check")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.title)
                .cornerRadius(20)
        }.padding()
            .onAppear {
                print("Appearing")
                self.capturedWords = []
                self.navigateToDefinition = false
            }

        let firstWord = capturedWords.first?.text ?? ""

        let destination = appState.mode == .single ? AnyView(DefinitionView(word: firstWord)) : AnyView(WordList(wordList: capturedWords))

        NavigationLink(destination: destination, isActive: self.$navigateToDefinition) {
            EmptyView()
        }
    }
}
