//
//  CameraPreview.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

// CameraPreview.swift

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var isCameraActive: Bool
    var onImageCaptured: (UIImage?) -> Void
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraPreviewViewController()
        viewController.onImageCaptured = onImageCaptured
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isCameraActive {
            (uiViewController as? CameraPreviewViewController)?.startSession()
        } else {
            (uiViewController as? CameraPreviewViewController)?.stopSession()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: CameraPreview

        init(_ parent: CameraPreview) {
            self.parent = parent
        }
    }
}

class CameraPreviewViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let photoOutput = AVCapturePhotoOutput()
    var onImageCaptured: ((UIImage?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    func captureImage() {
        let settings = AVCapturePhotoSettings()
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: { [weak self] image in
            self?.onImageCaptured?(image)
        })
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        else {
            return
        }

        if captureSession?.canAddInput(videoInput) ?? false {
            captureSession?.addInput(videoInput)
        } else {
            // Handle error: video input could not be added
            return
        }

        if captureSession?.canAddOutput(photoOutput) ?? false {
            captureSession?.addOutput(photoOutput)
        } else {
            // Handle error: photo output could not be added
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        sessionQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
}
