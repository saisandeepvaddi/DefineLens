//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst().lowercased()
    }
}

func cleanWord(_ word: String) -> String {
    let regex = "[^a-zA-Z0-9 \\-]" // Regular expression to match unwanted characters
    let cleanedWord = word.replacingOccurrences(of: regex, with: "", options: .regularExpression)
    let capitalizedWord = cleanedWord.capitalizingFirstLetter()
    return capitalizedWord
}

struct ContentView: View {
    @StateObject var cameraManager = CameraManager()
    @StateObject var appState = AppState()
    @State private var navigateToDefinition = false
    @State private var recognizedWord: String?

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(cameraManager: self.cameraManager)
                    .edgesIgnoringSafeArea(.all)

                if let previewLayer = cameraManager.previewLayer {
                    BoundingBoxesView(observations: self.cameraManager.textObservations, previewLayer: previewLayer, onWordChange: self.onWordChange)
                        .edgesIgnoringSafeArea(.all)
                        .environmentObject(self.appState)
                }

                Image(systemName: "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                VStack {
                    Spacer()
                    Button(action: {
                        self.snapWord()
                    }) {
                        Text(cleanWord(self.appState.word ?? "Check"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .font(.title)
                            .cornerRadius(20)
                    }.padding()
                }
                NavigationLink(destination: DefinitionView(word: self.appState.word), isActive: self.$navigateToDefinition) {
                    EmptyView()
                }
            }
        }
    }

    private func onWordChange(newWord: String) {
        self.appState.word = newWord
    }

    private func snapWord() {
        if let word = appState.word {
            self.navigateToDefinition = true
            self.recognizedWord = cleanWord(word)
        }
    }
}
