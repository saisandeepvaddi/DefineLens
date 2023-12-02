//
//  CameraManager.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//
import AVFoundation
import Combine
import SwiftUI
import UIKit
import Vision

let FRAMES_PER_SECOND = 24.0

class CameraManager: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var appState: AppState? {
        didSet {
            setupModeListener()
        }
    }

    private var modeSubscription: AnyCancellable?

    @Published var textObservations: [VNRecognizedTextObservation] = []
    @Published var isReady: Bool = false
    @Published var wordUnderCrosshair: String?
    let sessionQueue = DispatchQueue(label: "videoQueue")
    var capturedWordCallback: ((String?) -> Void)?
    private var lastUpdateTime = Date()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectsQueue = DispatchQueue(
        label: "metadata objects queue", attributes: [], target: nil)
    private var currentMode: Modes = .photo

    init(appState: AppState? = nil) {
        self.appState = appState
        super.init()
        print("initializing cameraManager")
        setupCaptureSession()
    }

    func setupModeListener() {
        guard let appState = appState else {
            print("AppState not available")
            return
        }

        modeSubscription = appState.$mode.sink { newMode in
            print("mode changed: \(newMode)")
            if newMode != self.currentMode {
                if newMode == .photo {
                    self.switchToPhotoMode()
                } else {
                    self.switchToVideoMode()
                }
                self.currentMode = newMode
            }
        }
    }

    func shouldUpdateBoundingBoxes() -> Bool {
        let currentTime = Date()
        let updateInterval = 1.0 / 10
        if currentTime.timeIntervalSince(lastUpdateTime) > updateInterval {
            lastUpdateTime = currentTime
            return true
        }
        return false
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let videoDevice = deviceDiscoverySession.devices.first ?? AVCaptureDevice.default(for: .video)
        guard let videoDevice = videoDevice else {
            logger.error("Device input not available..")
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        photoOutput = AVCapturePhotoOutput()

        guard let photoOutput = photoOutput else { return }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        if currentMode == .video {
            videoOutput = AVCaptureVideoDataOutput()
            guard let videoOutput = videoOutput else { return }

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            }
        }

        captureSession.sessionPreset = .photo

        captureSession.commitConfiguration()
    }

    func switchToPhotoMode() {
        sessionQueue.async { [weak self] in
            guard let self = self, let captureSession = self.captureSession else { return }

            captureSession.beginConfiguration()

            if let videoOutput = self.videoOutput {
                captureSession.removeOutput(videoOutput)
            }

            if photoOutput == nil {
                photoOutput = AVCapturePhotoOutput()
            }

            guard let photoOutput = photoOutput else { return }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            captureSession.commitConfiguration()
            print("Switched to Photo")
        }
    }

    func switchToVideoMode() {
        sessionQueue.async { [weak self] in
            guard let self = self, let captureSession = self.captureSession else { return }

            captureSession.beginConfiguration()

            if let photoOutput = self.photoOutput {
                captureSession.removeOutput(photoOutput)
            }

            if videoOutput == nil {
                videoOutput = AVCaptureVideoDataOutput()
            }

            guard let videoOutput = videoOutput else {
                return
            }

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            }

            captureSession.commitConfiguration()
            print("Switched to video")
        }
    }

    func captureWordInPhotoMode(callback: @escaping ((String?) -> Void)) {
        print("Capturing in photo mode")
        guard let photoOutput = photoOutput else { return }
        capturedWordCallback = callback
//        if capturedWordCallback == nil {
//            capturedWordCallback = callback
//        }
        let photoSettings = AVCapturePhotoSettings()
        if let photoOutputConnection = photoOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = .portrait
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func captureWordInVideoMode(callback: @escaping ((String?) -> Void)) {
        print("Capturing in video mode")
        guard videoOutput != nil else { return }

        // Since video buffer is continuously running, just setting the callback will trigger the word
        capturedWordCallback = callback
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
    func photoOutput(
        _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        guard let cgImage = photo.cgImageRepresentation() else {
            print("No CGImage")
            return
        }

        let cgOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32

        guard let cgOrientation = cgOrientation,
              let cgOrientation = CGImagePropertyOrientation(rawValue: cgOrientation)
        else {
            print("No orientation")
            return
        }

        let uiOrientation = cgImagePropertyOrientationToUIImageOrientation(cgOrientation)

        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: uiOrientation)

        processFrameImage(image)
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

            //            drawAnnotations(image: uiImage, observations: observations)

            self?.updateObservationsForBuffer(observations, imageBounds: imageBounds)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(
            cgImage: cgImage, orientation: getCGImageOrientation(from: uiImage), options: [:])
        try? imageRequestHandler.perform([request])
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection)
    {
        if currentMode == .photo {
            //            We don't process frames if it's photo mode
            return
        }
        if !shouldUpdateBoundingBoxes() {
            return
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processFrameBuffer(pixelBuffer)
    }

    func processFrameBuffer(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            guard let previewLayer = self?.previewLayer else {
                print("No preview layer")
                return
            }
            let bounds = previewLayer.bounds
            self?.updateObservationsForBuffer(observations, imageBounds: bounds)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: cgImagePropertyOrientation(from: UIDevice.current.orientation))

        try? imageRequestHandler.perform([request])
    }

    func updateObservationsForBuffer(
        _ observations: [VNRecognizedTextObservation], imageBounds: CGRect)
    {
        let crosshairPosition = CGPoint(x: imageBounds.midX, y: imageBounds.midY)
        var boxes = [CGRect]()
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

                            if currentMode == .video {
                                boxes.append(wordBoundingBoxTransformed)
                            }

                            if wordBoundingBoxTransformed.contains(crosshairPosition) {
                                DispatchQueue.main.async {
                                    self.textObservations = [observation]
                                    self.wordUnderCrosshair = word
                                    if let callback = self.capturedWordCallback {
                                        callback(word)
                                        // Prevent setting word multiple times in video mode while it redirects
                                        // until next button click
                                        self.capturedWordCallback = nil
                                    }
                                }
                            }
                        } catch {
                            print("Error in wordRange")
                        }
                    }
                }
            }

            if currentMode == .video {
                DispatchQueue.main.async {
                    self.appState?.boundingBoxes = boxes
                }
            }
        }
    }
}
