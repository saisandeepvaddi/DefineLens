//
//  CaptureButton.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/27/23.
//

import SwiftUI

struct CaptureButton: View {
    @EnvironmentObject var cameraManager: CameraManager
    var body: some View {
        Button(action: {
            cameraManager.capturePhoto()
        }) {
            Text("Check")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.title)
                .cornerRadius(20)
        }.padding()
    }
}

#Preview {
    CaptureButton()
}
