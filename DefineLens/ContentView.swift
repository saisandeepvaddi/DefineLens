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
    @EnvironmentObject var appState: AppState

    @State private var navigateToSettings = false
    @State private var recognizedWord: String?

    var body: some View {
        NavigationView {
            ZStack {
                CameraContainer()
                    .edgesIgnoringSafeArea(.all)
                CrosshairView()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                        .frame(height: 50)
                    HStack {
                        Spacer()
                        Button(action: {
                            self.navigateToSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .frame(width: 50, height: 50)
                                .padding(.all)
                        }
                    }
                    Spacer()
                    CaptureButton()
                }

                NavigationLink(destination: SettingsView(), isActive: self.$navigateToSettings) {
                    EmptyView()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

//    private func onWordChange(newWord: String) {
//        self.appState.word = newWord
//    }
//
//    private func snapWord() {
//        if let word = appState.word {
//            self.navigateToDefinition = true
//            self.recognizedWord = cleanWord(word)
//        }
//    }
}
