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
        if capturedWordCallback == nil {
            capturedWordCallback = callback
        }
        let photoSettings = AVCapturePhotoSettings()
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

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let ciImage = CIImage(data: imageData) else {
            print("No Image data")
            return
        }

        processFrameImage(ciImage)
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData),
//              let pixelBuffer = image.pixelBuffer()
//        else {
//            return
//        }
//        processFrameBuffer(pixelBuffer)
    }

    func processFrameImage(_ ciImage: CIImage) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let imageBounds = ciImage.extent

            self?.updateObservationsForBuffer(observations, imageBounds: imageBounds)
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

            let imageBounds = CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight))
            self?.updateObservationsForBuffer(observations, imageBounds: imageBounds)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientationForDeviceOrientation(), options: [:])

        try? imageRequestHandler.perform([request])
    }

    func updateObservationsForBuffer(_ observations: [VNRecognizedTextObservation], imageBounds: CGRect) {
//        let screenBounds = UIScreen.main.bounds

//        let crosshairPosition = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
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
    }
}

extension CameraManager {
    func convertToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = size.width
        let height = size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)

        if status != kCVReturnSuccess {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(width),
                                height: Int(height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}

extension CGRect {
    func expandBy(widthFactor: CGFloat, heightFactor: CGFloat) -> CGRect {
        let widthExpansion = width * widthFactor
        let heightExpansion = height * heightFactor
        return insetBy(dx: -widthExpansion, dy: -heightExpansion)
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
