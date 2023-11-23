//
//  Utils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import Foundation
import UIKit
import Vision

func recognizeTextAndHighlight(from image: UIImage, completion: @escaping (String?) -> Void) {
    guard let cgImage = image.cgImage else {
        completion(nil)
        return
    }

    let request = VNRecognizeTextRequest { request, error in
        guard error == nil else {
            completion(nil)
            return
        }

        // Calculate crosshair position
        let crosshairX = cgImage.width / 2
        let crosshairY = cgImage.height / 2

        let observations = request.results as? [VNRecognizedTextObservation]

        let imageSize = image.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: .zero)

        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(2)

        observations?.forEach { observation in
            var boundingBox = observation.boundingBox
            boundingBox.origin.y = 1 - boundingBox.origin.y

            let scaledRect = VNImageRectForNormalizedRect(boundingBox, Int(imageSize.width), Int(imageSize.height))
            context?.addRect(scaledRect)
        }

        context?.strokePath()

        context?.setFillColor(UIColor.blue.cgColor)
        let crosshairCenter = CGPoint(x: crosshairX, y: crosshairY)
        context?.addEllipse(in: CGRect(x: crosshairCenter.x, y: crosshairCenter.y, width: 20, height: 20))
        context?.fillPath()

        // Extract the annotated image
        let annotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let annotatedImage = annotatedImage {
            UIImageWriteToSavedPhotosAlbum(annotatedImage, nil, nil, nil)
        }

        let recognizedStrings = observations?.compactMap { observation in
            var boundingBox = observation.boundingBox

            boundingBox.origin.y = 1 - boundingBox.origin.y
            let scaledRect = VNImageRectForNormalizedRect(boundingBox, Int(cgImage.width), Int(cgImage.height))

            if scaledRect.contains(CGPoint(x: crosshairX, y: crosshairY)) {
                return observation.topCandidates(1).first?.string
            }
            return nil
        }

        if recognizedStrings?.count == 0 {
            print("No words found")
        }

        let combinedText = recognizedStrings?.joined(separator: "\n")
        completion(combinedText)
    }

    let requests = [request]

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform(requests)
        } catch {
            completion(nil)
        }
    }
}
