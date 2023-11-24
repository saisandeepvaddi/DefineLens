//
//  MLTextRecognizer.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/23/23.
//

import AVFoundation
import Foundation
import MLKit
import MLKitTextRecognition

import UIKit

class MLTextRecognizer: NSObject, ObservableObject {
    let textRecognizer = TextRecognizer.textRecognizer(options: TextRecognizerOptions())
    let imageUtils = ImageUtils()
    typealias TextFromBuffer = (Text?) -> Void

    func createVisionImageFromBuffer(from buffer: CMSampleBuffer) -> VisionImage {
        let image = VisionImage(buffer: buffer)
        let deviceOrientation = UIDevice.current.orientation
        let cameraPosition = AVCaptureDevice.default(for: .video)?.position
        image.orientation = imageUtils.imageOrientation(deviceOrientation: deviceOrientation, cameraPosition: cameraPosition ?? .back)
        return image
    }

    func createVisionImageFromUIImage(from uiImage: UIImage) -> VisionImage {
        let image = VisionImage(image: uiImage)
        image.orientation = uiImage.imageOrientation
        print("Orientation: \(image.orientation)")
//        image.orientation = image.orientation = imageUtils.imageOrientation(deviceOrientation: deviceOrientation, cameraPosition: cameraPosition ?? .back)
//        let cameraPosition = AVCaptureDevice.default(for: .video)?.position
//        let deviceOrientation = UIDevice.current.orientation
//        image.orientation = imageUtils.imageOrientation(deviceOrientation: deviceOrientation, cameraPosition: cameraPosition ?? .back)
        return image
    }

    func getTextFromBuffer(from buffer: CMSampleBuffer, completion: @escaping TextFromBuffer) {
        let image = createVisionImageFromBuffer(from: buffer)
        textRecognizer.process(image) { result, error in
            guard error == nil, let result = result else {
                logger.error("Error: \(error)")
                completion(nil)
                return
            }
            completion(result)
        }
    }

    func getTextFromImage(from uiImage: UIImage, completion: @escaping TextFromBuffer) {
        let image = createVisionImageFromUIImage(from: uiImage)
        textRecognizer.process(image) { result, error in
            guard error == nil, let result = result else {
                logger.error("Error: \(error)")
                completion(nil)
                return
            }
            completion(result)
        }
    }
}
