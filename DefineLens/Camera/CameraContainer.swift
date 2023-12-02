//
//  CameraContainer.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/26/23.
//

import SwiftUI

struct CameraContainer: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cameraManager: CameraManager

    var body: some View {
        CameraPreview(cameraManager: self.cameraManager)
            .onAppear {
                print("Changing state")
                self.cameraManager.appState = appState
            }
    }
}
