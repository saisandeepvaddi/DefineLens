//
//  CameraPreview.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import AVFoundation
import SwiftUI
import UIKit

class CameraViewController: UIViewController {
    var cameraManager: CameraManager
    var previewLayer: AVCaptureVideoPreviewLayer?

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPreviewLayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.cameraManager.captureSession?.startRunning()
            DispatchQueue.main.async {
                self.previewLayer?.frame = self.view.bounds
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }

    func addPreviewLayer() {
        guard let captureSession = cameraManager.captureSession else {
            print("No capture session")
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else {
            print("Failed to create preview layer")
            return
        }

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }

    func removePreviewlayer() {
        if let previewLayer = previewLayer {
            previewLayer.removeFromSuperlayer()
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    var cameraManager: CameraManager
    func makeUIViewController(context: Context) -> some UIViewController {
        let content = CameraViewController(
            cameraManager: cameraManager
        )

        return content
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
