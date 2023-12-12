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
    //    var previewLayer: AVCaptureVideoPreviewLayer?

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
    }

    func showSettingsAlert() {
        let alert = UIAlertController(title: "Camera Access Required",
                                      message: "Please enable camera access in your settings.",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })

        present(alert, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraManager.checkCameraPermissions { [weak self] granted in
            if !granted {
                self?.showSettingsAlert()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self?.cameraManager.setupCaptureSession()
                DispatchQueue.main.async {
                    self?.addPreviewLayer()
                    self?.cameraManager.previewLayer?.frame = self?.view?.bounds ?? CGRect.zero
                }

                self?.cameraManager.captureSession?.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }

    func addPreviewLayer() {
        guard let captureSession = cameraManager.captureSession else {
            return
        }
        cameraManager.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = cameraManager.previewLayer else {
            print("Failed to create preview layer")
            return
        }

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }

    func removePreviewlayer() {
        if let previewLayer = cameraManager.previewLayer {
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
