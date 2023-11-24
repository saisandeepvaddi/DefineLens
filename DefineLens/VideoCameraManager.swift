//
//  VideoTextRecognizer.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/23/23.
//

import AVFoundation
import UIKit
import Vision

class VideoCameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var backCamera: AVCaptureDevice?
    private var captureCompletionHandler: ((CVPixelBuffer?) -> Void)?
    private let queue = DispatchQueue(label: "VideoQueue")

    @Published var detectedText: [String] = []
    @Published var boundingBoxes: [CGRect] = []
    @Published var videoSize: CGSize = .zero
    @Published var isRunning: Bool = false

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                session.sessionPreset = .high
            }
            videoOutput.setSampleBufferDelegate(self, queue: queue)

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
        } catch {
            print("Setup video camera output: \(error)")
        }
    }

    func startSession() {
        print("Starting session")
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }

    func stopSession() {
        print("Stopping session")
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }

    func toggleSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
            isRunning = true
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
            isRunning = false
        }
    }
}

extension VideoCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processBuffer(sampleBuffer)
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//
//        do {
//            try imageRequestHandler.perform([textDetectionRequest])
//            // The completion handler of the text detection request should update the UI
//            // with the detected bounding boxes. This has to be done on the main thread.
//        } catch {
//            print(error)
//        }
    }
}

extension VideoCameraManager {
    private func processBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
            let frameHeight = CVPixelBufferGetHeight(pixelBuffer)
            DispatchQueue.main.async {
                self?.videoSize = CGSize(width: frameWidth, height: frameHeight)
            }
//            print("Video size: \(self?.videoSize)")
            self?.handleDetectedText(observations)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
        try? handler.perform([request])
    }

    private func handleDetectedText(_ observations: [VNRecognizedTextObservation]) {
        DispatchQueue.main.async {
            self.detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
//            print("self.detectedText: \(self.detectedText)")
            self.boundingBoxes = observations.map { observation in
//                convertBoundingBoxCoordinates(boundingBox: $0.boundingBox, to: UIScreen.main.bounds)
                observation.boundingBox
            }
//            self.boundingBoxes = observations.map { $0.boundingBox }
        }
    }
}
