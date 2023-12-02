//
//  ImageUtils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/27/23.
//

import AVFoundation
import UIKit
import Vision

// extension UIImage.Orientation {
//    init(_ cgOrientation: CGImagePropertyOrientation) {
//        switch cgOrientation {
//        case .up: self = .up
//        case .down: self = .down
//        case .left: self = .left
//        case .right: self = .right
//        case .upMirrored: self = .upMirrored
//        case .downMirrored: self = .downMirrored
//        case .leftMirrored: self = .leftMirrored
//        case .rightMirrored: self = .rightMirrored
//        }
//    }
// }

func saveImageToPhotos(_ image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}

func convertToUIImage(from pixelBuffer: CVPixelBuffer) -> UIImage? {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}

func createUIImage(from ciImage: CIImage) -> UIImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}

func drawAnnotations(image: UIImage, observations: [VNRecognizedTextObservation]) {
    guard let cgImage = image.cgImage else {
        print("No cgImage to save image")
        return
    }
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    let crosshairX = image.size.width / 2
    let crosshairY = image.size.height / 2
    let size = CGSize(width: image.size.width, height: image.size.height)
    let bounds = CGRect(origin: .zero, size: image.size)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    image.draw(at: .zero)

    context?.setStrokeColor(UIColor.red.cgColor)
    context?.setLineWidth(2)

    observations.forEach { observation in
        let boundingBox = observation.boundingBox
        let fixedBoundingBox = transformBoundingBox(boundingBox, for: bounds)

        context?.addRect(fixedBoundingBox)
    }

    context?.strokePath()

    context?.setFillColor(UIColor.blue.cgColor)
    let crosshairCenter = CGPoint(x: crosshairX, y: crosshairY)
    let ellipseSize = CGSize(width: 20, height: 20)
    let ellipseOrigin = CGPoint(x: crosshairCenter.x - ellipseSize.width / 2, y: crosshairCenter.y - ellipseSize.height / 2)
    context?.addEllipse(in: CGRect(origin: ellipseOrigin, size: ellipseSize))

    context?.fillPath()

    // Extract the annotated image
    let annotatedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    if let annotatedImage = annotatedImage {
        UIImageWriteToSavedPhotosAlbum(annotatedImage, nil, nil, nil)
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

func getUIImageOrientation() -> UIImage.Orientation {
    // This example assumes portrait orientation. Adjust as necessary for your app's supported orientations.
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
            return .right // Default to portrait
    }
}

func getDeviceCGImageOrientation() -> CGImagePropertyOrientation {
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

func getCGImageOrientation(from uiImage: UIImage) -> CGImagePropertyOrientation {
    switch uiImage.imageOrientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default:
            return .right
    }
}

func cgImagePropertyOrientationToUIImageOrientation(_ value: CGImagePropertyOrientation)
    -> UIImage.Orientation
{
    switch value {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
    }
}

func cgImagePropertyOrientation(from deviceOrientation: UIDeviceOrientation)
    -> CGImagePropertyOrientation
{
    switch deviceOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        case .faceUp, .faceDown, .unknown:
            return .up
        @unknown default:
            return .up
    }
}
