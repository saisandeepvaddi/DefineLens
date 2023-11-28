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
        cameraManager.addPreviewLayer(to: view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraManager.startCaptureSession()
        cameraManager.addPreviewLayer(to: view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
        cameraManager.removePreviewLayer()
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    var cameraManager: CameraManager
    func makeUIViewController(context: Context) -> some UIViewController {
        return CameraViewController(
            cameraManager: cameraManager
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
