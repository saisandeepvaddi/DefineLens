//
//  CameraContainer.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/26/23.
//

import SwiftUI

struct CameraContainer: View {
    var geometry: GeometryProxy
    @StateObject var cameraManager: CameraManager
    init(geometry: GeometryProxy) {
        self.geometry = geometry
        _cameraManager = StateObject(wrappedValue: CameraManager(geometry: geometry))
    }

    var body: some View {
        if cameraManager.isReady {
            CameraPreview(cameraManager: self.cameraManager)
                .edgesIgnoringSafeArea(.all)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
