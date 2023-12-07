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

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.navigateToSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .frame(width: 50, height: 50)
                                .padding(.all)
                        }
                        .padding(.top, 20)
                    }
                    .frame(height: geo.size.height * 0.15)
                    ZStack {
                        CameraContainer()
                            .edgesIgnoringSafeArea(.all)
                        if appState.mode == .single {
                            CrosshairView()
                                .edgesIgnoringSafeArea(.all)
                        }
                        ModeChanger()
                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
                        if appState.mode == .multi {
                            BoundingBoxes()
                        }
                    }
                    VStack {
                        Spacer()
                        CaptureButton()
                            .padding(10)
                    }
                    .frame(height: geo.size.height * 0.15)

                    NavigationLink(destination: SettingsView(), isActive: self.$navigateToSettings) {
                        EmptyView()
                    }
                }
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

// #Preview {
//    ContentView()
// }
