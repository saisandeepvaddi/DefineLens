//
//  CameraManager.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//
import AVFoundation
import SwiftUI
import UIKit
import Vision

let FRAMES_PER_SECOND = 24.0

class CameraManager: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var appState: AppState?
    @Published var textObservations: [VNRecognizedTextObservation] = []
    @Published var isReady: Bool = false
    @Published var wordUnderCrosshair: String?
    let sessionQueue = DispatchQueue(label: "videoQueue")
    var capturedWordCallback: ((String?) -> Void)?
    private let frameProcessingInterval: TimeInterval = 1.0 / FRAMES_PER_SECOND
    private var lastFrameProcessingTime: TimeInterval = 0

    init(appState: AppState? = nil) {
        self.appState = appState
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            logger.error("Device input not available..")
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else { return }

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }

        photoOutput = AVCapturePhotoOutput()

        guard let photoOutput = photoOutput else { return }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.sessionPreset = .photo

        captureSession.commitConfiguration()
    }

    func capturePhoto(callback: @escaping ((String?) -> Void)) {
        guard let photoOutput = photoOutput else { return }
        capturedWordCallback = callback
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func addPreviewLayer(to view: UIView) {
        guard let captureSession = captureSession, previewLayer == nil else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }

    func removePreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    func stopCaptureSession() {
        captureSession?.stopRunning()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let ciImage = CIImage(data: imageData) else {
            print("No Image data")
            return
        }

        processFrameImage(ciImage)
    }

    func processFrameImage(_ ciImage: CIImage) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            self?.updateObservationsForBuffer(observations)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: orientationForDeviceOrientation(), options: [:])
        try? imageRequestHandler.perform([request])
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        logger.info("Getting buffer output: \(Date.now)")

//        let currentTime = CACurrentMediaTime()
//        if currentTime - lastFrameProcessingTime >= frameProcessingInterval {
//            lastFrameProcessingTime = currentTime
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//            processFrame(pixelBuffer)
//        }
    }

    func processFrameBuffer(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let imageWidth = CVPixelBufferGetWidth(pixelBuffer)
            let imageHeight = CVPixelBufferGetHeight(pixelBuffer)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)

            self?.updateObservationsForBuffer(observations)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientationForDeviceOrientation(), options: [:])

        try? imageRequestHandler.perform([request])
    }

    func updateObservationsForBuffer(_ observations: [VNRecognizedTextObservation]) {
        let screenBounds = UIScreen.main.bounds

        let crosshairPosition = CGPoint(x: screenBounds.midX, y: screenBounds.midY)

        for observation in observations {
            let boundingBox = observation.boundingBox
            let transformedBox = transformBoundingBox(boundingBox, for: screenBounds)

            if transformedBox.contains(crosshairPosition) {
                guard let candidate = observation.topCandidates(1).first else { continue }
                let fullString = candidate.string
                let words = fullString.split(separator: " ").map(String.init)
                for word in words {
                    if let wordRange = fullString.range(of: word) {
                        do {
                            let boxObservation = try candidate.boundingBox(for: wordRange)
                            guard let boxObservation = boxObservation else {
                                continue
                            }

                            let wordBoundingBox = boxObservation.boundingBox
                            let wordBoundingBoxTransformed = transformBoundingBox(
                                wordBoundingBox, for: screenBounds)
//                            print("Bounding box: \(wordBoundingBoxTransformed) \(crosshairPosition)\(wordBoundingBoxTransformed.contains(crosshairPosition))")
                            if wordBoundingBoxTransformed.contains(crosshairPosition) {
//                                logger.info("In Word: \(word)")
                                DispatchQueue.main.async {
                                    self.textObservations = [observation]
                                    self.wordUnderCrosshair = word
                                    if let callback = self.capturedWordCallback {
                                        callback(word)
                                    }
                                }
//                                drawBoundingBox(wordBoundingBoxTransformed, on: drawingLayer)
//
//                                DispatchQueue.main.async {
//                                    onWordChange(word)
//                                }
                            }
                        } catch {
                            print("Error in wordRange")
                        }
                    }
                }
            }
        }
//        DispatchQueue.main.async {
//            self.textObservations = observations
//        }
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
