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
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var geometry: GeometryProxy
    @Published var textObservations: [VNRecognizedTextObservation] = []
    @Published var isReady: Bool = false

    private let frameProcessingInterval: TimeInterval = 1.0 / FRAMES_PER_SECOND
    private var lastFrameProcessingTime: TimeInterval = 0

    init(geometry: GeometryProxy) {
        self.geometry = geometry
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()

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
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
//            DispatchQueue.main.async {
//                self.isReady = true
//            }
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
            self.isReady = true
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
            self?.updateObservations(observations, pixelBuffer)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientationForDeviceOrientation(), options: [:])

        try? imageRequestHandler.perform([request])
    }

    func updateObservations(_ observations: [VNRecognizedTextObservation], _ pixelBuffer: CVPixelBuffer) {
//        let screenBounds = UIScreen.main.bounds
        let screenBounds = geometry.frame(in: .global)
//        print("Screen:Geometry -> \(screenBounds) \(geometry.frame(in: .global).size)")
        let crosshairPosition = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
        let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
        let bufferSize = CGSize(width: bufferWidth, height: bufferHeight)

        let bufferBounds = CGRect(origin: .zero, size: bufferSize)

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

                            if wordBoundingBoxTransformed.contains(crosshairPosition) {
//                                logger.info("Word: \(word)")
                                DispatchQueue.main.async {
                                    self.textObservations = [observation]
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
