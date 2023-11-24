//
//  DefineLensApp.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import os.log
import SwiftUI

@main
struct DefineLensApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

let logger = Logger(subsystem: "com.saisandeepvaddi.DefineLens", category: "Camera")
