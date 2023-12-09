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
    var capturedWordCallback: (([CustomRecognizedText]?) -> Void)?
    private var lastUpdateTime = Date()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectsQueue = DispatchQueue(
        label: "metadata objects queue", attributes: [], target: nil)
    private var currentMode: Modes = .single

    private var videoDevice: AVCaptureDevice?

    init(appState: AppState? = nil) {
        self.appState = appState
        super.init()
        print("initializing cameraManager")
        setupCameraDevice()
//        setupCameraFocus()
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "focusMode" {
            if let newValue = change?[.newKey] {
                print("Focus mode changed to: \(newValue)")
            }
        } else if keyPath == "lensPosition" {
            if let newValue = change?[.newKey] {
                print("Lens position changed to: \(newValue)")
            }
        }
    }

    private func setupCameraDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTripleCamera, .builtInDualCamera], mediaType: .video, position: .back)
        videoDevice = deviceDiscoverySession.devices.first ?? AVCaptureDevice.default(for: .video)
    }

    private func setupCameraFocus() {
        guard let videoDevice = videoDevice else {
            logger.error("Device input not available..")
            return
        }

        do {
            try videoDevice.lockForConfiguration()

            videoDevice.isSubjectAreaChangeMonitoringEnabled = true
            if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                print("Setting focus")
                videoDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                videoDevice.focusMode = .continuousAutoFocus
            }

            videoDevice.exposureMode = .continuousAutoExposure

            if videoDevice.isSmoothAutoFocusSupported {
                videoDevice.isSmoothAutoFocusEnabled = true
            }

            // TODO: Add a slider
            if videoDevice.deviceType != AVCaptureDevice.DeviceType.builtInWideAngleCamera {
                videoDevice.videoZoomFactor = 2.0
            }

            videoDevice.unlockForConfiguration()

        } catch {
            print("Unable to add focus config")
        }
    }

    private func setupCaptureSession() {
        guard let videoDevice = videoDevice else {
            logger.error("Device input not available..")
            return
        }

        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        setupCameraFocus()

        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else { return }

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }

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

    func captureWordInVideoMode(callback: @escaping (([CustomRecognizedText]?) -> Void)) {
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

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection)
    {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if capturedWordCallback != nil {
            processFrameBuffer(pixelBuffer)
        }
    }

    func processFrameBuffer(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            guard let previewLayer = self?.previewLayer else {
                print("No preview layer")
                return
            }
            let bounds = previewLayer.bounds
            if self?.currentMode == .single {
                self?.processObservationsInSingleMode(observations, imageBounds: bounds)
            } else {
                self?.processObservationsInMultiMode(observations, imageBounds: bounds)
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: cgImagePropertyOrientation(from: UIDevice.current.orientation))

        try? imageRequestHandler.perform([request])
    }

    func processObservationsInSingleMode(_ observations: [VNRecognizedTextObservation], imageBounds: CGRect) {
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
                                let newWord = CustomRecognizedText(text: word, boundingBox: wordBoundingBoxTransformed)
                                DispatchQueue.main.async {
                                    if let callback = self.capturedWordCallback {
                                        callback([newWord])
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
        }
    }

    func processObservationsInMultiMode(_ observations: [VNRecognizedTextObservation], imageBounds: CGRect) {
        var detectedWords = [CustomRecognizedText]()
        for observation in observations {
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

                        let newWord = CustomRecognizedText(
                            text: word, boundingBox: wordBoundingBoxTransformed)

                        detectedWords.append(newWord)

                    } catch {
                        print("Error in wordRange")
                    }
                }
            }
        }

        DispatchQueue.main.async {
            if let callback = self.capturedWordCallback {
                callback(detectedWords)
                self.capturedWordCallback = nil
            }
        }
    }
}
