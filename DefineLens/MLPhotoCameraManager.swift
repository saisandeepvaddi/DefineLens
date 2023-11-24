//
//  MLPhotoCameraManager.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/24/23.
//

import AVFoundation
import MLKit
import UIKit

class MLPhotoCameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var backCamera: AVCaptureDevice?
    private var captureCompletionHandler: ((Text?, UIImage?) -> Void)?
    private var mlTextRecognizer = MLTextRecognizer()
    @Published var blocks = [TextBlock]()

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        session.beginConfiguration()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        guard let camera = deviceDiscoverySession.devices.first else { return }
        backCamera = camera

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        } catch {
            print(error)
        }

        session.commitConfiguration()
    }

    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }

    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }

    func captureImage(completion: @escaping (Text?, UIImage?) -> Void) {
        captureCompletionHandler = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension MLPhotoCameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
//              let pixelBuffer = image.pixelBuffer()
        else {
            captureCompletionHandler?(nil, nil)
            return
        }

        guard let captureCompletionHandler = captureCompletionHandler else {
            logger.error("No captureCompletionError provided")
            return
        }

        mlTextRecognizer.getTextFromImage(from: image) { text in
            guard let blocks = text?.blocks else {
                print("No Blocks")
                captureCompletionHandler(text, image)
                return
            }
            self.blocks = blocks
            captureCompletionHandler(text, image)
        }

//        captureCompletionHandler?(pixelBuffer)
//        captureCompletionHandler = nil
    }
}

extension MLPhotoCameraManager {
    func convertToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// extension UIImage {
//    func pixelBuffer() -> CVPixelBuffer? {
//        let width = size.width
//        let height = size.height
//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        var pixelBuffer: CVPixelBuffer?
//        let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                         Int(width),
//                                         Int(height),
//                                         kCVPixelFormatType_32ARGB,
//                                         attrs,
//                                         &pixelBuffer)
//
//        if status != kCVReturnSuccess {
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: pixelData,
//                                width: Int(width),
//                                height: Int(height),
//                                bitsPerComponent: 8,
//                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
//                                space: rgbColorSpace,
//                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//
//        context?.translateBy(x: 0, y: height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//
//        UIGraphicsPushContext(context!)
//        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//        UIGraphicsPopContext()
//        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//        return pixelBuffer
//    }
// }
