//
//  CameraPreview.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI
import UIKit

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.frame
            print("Added preview Layer")

            view.layer.addSublayer(previewLayer)
        } else {
            print("No preview Layer")
        }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.frame
            if previewLayer.superlayer != uiView.layer {
                uiView.layer.addSublayer(previewLayer)
            }
        } else {
            for layer in uiView.layer.sublayers ?? [] {
                layer.removeFromSuperlayer()
            }
        }
    }
}
