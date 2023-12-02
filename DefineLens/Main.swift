//
//  DefineLensApp.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import os.log
import SwiftUI

@main
struct Main: App {
    @StateObject var appState = AppState()
    @StateObject var cameraManager = CameraManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .edgesIgnoringSafeArea(.all)
                .environmentObject(appState)
                .environmentObject(cameraManager)
        }
    }
}

let logger = Logger(subsystem: "com.saisandeepvaddi.DefineLens", category: "Camera")
