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

    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectsQueue = DispatchQueue(label: "metadata objects queue", attributes: [], target: nil)

    init(appState: AppState? = nil) {
        self.appState = appState
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let videoDevice = deviceDiscoverySession.devices.first ?? AVCaptureDevice.default(for: .video)
        guard let videoDevice = videoDevice else {
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
        if capturedWordCallback == nil {
            capturedWordCallback = callback
        }
        let photoSettings = AVCapturePhotoSettings()
        if let photoOutputConnection = photoOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = .portrait
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func addPreviewLayer(to view: UIView) {
        guard let captureSession = captureSession, previewLayer == nil else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }

    func removePreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    func startCaptureSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopCaptureSession() {
        captureSession?.stopRunning()
    }
}

func cgImagePropertyOrientationToUIImageOrientation(_ value: CGImagePropertyOrientation) -> UIImage.Orientation {
    switch value {
    case .up: return .up
    case .upMirrored: return .upMirrored
    case .down: return .down
    case .downMirrored: return .downMirrored
    case .left: return .left
    case .leftMirrored: return .leftMirrored
    case .right: return .right
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("No Image data")
            return
        }

        guard let cgImage = photo.cgImageRepresentation() else {
            print("No CGImage")
            return
        }

        let cgOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32
        print("Something: \(cgOrientation)")

        guard let cgOrientation = cgOrientation, let cgOrientation = CGImagePropertyOrientation(rawValue: cgOrientation) else {
            print("No orientation")
            return
        }

        let uiOrientation = cgImagePropertyOrientationToUIImageOrientation(cgOrientation)

        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: uiOrientation)

//        let newImage = convertToUIImage(from: pixelBuffer)
//        guard let image = newImage else {
//            print("No image captured")
//            return
//        }
        saveImageToPhotos(image)
        processFrameImage(image)
//        if let newImage = newImage {
//            print("Saving")
//            saveImageToPhotos(newImage)
//        }
//        saveImageToPhotos(uiImage)
//        processFrameImage(uiImage)
    }

    func processFrameImage(_ uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            let imageBounds = CGRect(origin: .zero, size: imageSize)

//            let image = UIImage(cgImage: cgImage)
//
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            drawAnnotations(image: uiImage, observations: observations)

            self?.updateObservationsForBuffer(observations, imageBounds: imageBounds)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: getCGImageOrientation(from: uiImage), options: [:])
        try? imageRequestHandler.perform([request])
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func processFrameBuffer(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let imageWidth = CVPixelBufferGetWidth(pixelBuffer)
            let imageHeight = CVPixelBufferGetHeight(pixelBuffer)

            let imageBounds = CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight))

            self?.updateObservationsForBuffer(observations, imageBounds: imageBounds)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])

        try? imageRequestHandler.perform([request])
    }

    func updateObservationsForBuffer(_ observations: [VNRecognizedTextObservation], imageBounds: CGRect) {
        let crosshairPosition = CGPoint(x: imageBounds.midX, y: imageBounds.midY)
        for observation in observations {
            let boundingBox = observation.boundingBox
            let transformedBox = transformBoundingBox(boundingBox, for: imageBounds)

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
                                wordBoundingBox, for: imageBounds)

                            if wordBoundingBoxTransformed.contains(crosshairPosition) {
                                DispatchQueue.main.async {
                                    self.textObservations = [observation]
                                    self.wordUnderCrosshair = word
                                    if let callback = self.capturedWordCallback {
                                        callback(word)
                                    }
                                }
                            }
                        } catch {
                            print("Error in wordRange")
                        }
                    }
                }
            }
        }
    }
}

extension CGRect {
    func expandBy(widthFactor: CGFloat, heightFactor: CGFloat) -> CGRect {
        let widthExpansion = width * widthFactor
        let heightExpansion = height * heightFactor
        return insetBy(dx: -widthExpansion, dy: -heightExpansion)
    }
}
