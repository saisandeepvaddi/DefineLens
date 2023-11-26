//
//  CameraManager.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//
import AVFoundation
import UIKit
import Vision

let FRAMES_PER_SECOND = 24.0

class CameraManager: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    @Published var textObservations: [VNRecognizedTextObservation] = []

    private let frameProcessingInterval: TimeInterval = 1.0 / FRAMES_PER_SECOND
    private var lastFrameProcessingTime: TimeInterval = 0

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else { return }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        }
        setupPreviewLayer()
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }

    private func setupPreviewLayer() {
        DispatchQueue.main.async {
            guard let captureSession = self.captureSession else {
                print("No capture session to setupPreview")
                return
            }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = .resizeAspectFill
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = CACurrentMediaTime()
        if currentTime - lastFrameProcessingTime >= frameProcessingInterval {
            lastFrameProcessingTime = currentTime
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            processFrame(pixelBuffer)
        }
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            self?.updateObservations(observations)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientationForDeviceOrientation(), options: [:])

        try? imageRequestHandler.perform([request])
    }

    func updateObservations(_ observations: [VNRecognizedTextObservation]) {
        DispatchQueue.main.async {
            self.textObservations = observations
        }
    }
}

func orientationForDeviceOrientation() -> CGImagePropertyOrientation {
    switch UIDevice.current.orientation {
    case .portrait:
        return .right
    case .portraitUpsideDown:
        return .left
    case .landscapeLeft:
        return .up
    case .landscapeRight:
        return .down
    default:
        return .right // Default to portrait orientation if unknown
    }
}
