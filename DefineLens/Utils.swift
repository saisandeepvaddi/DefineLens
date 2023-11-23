//
//  Utils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import Foundation
import UIKit
import Vision

// From: https://stackoverflow.com/a/73399681/7376662
func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
    let imageWidth = bounds.width
    let imageHeight = bounds.height

    // Begin with input rect.
    var rect = boundingBox

    // Reposition origin.
    rect.origin.x *= imageWidth
    rect.origin.x += bounds.minX
    rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY

    // Rescale normalized coordinates.
    rect.size.width *= imageWidth
    rect.size.height *= imageHeight

    return rect
}

func drawAnnotations(image: UIImage, cgImage: CGImage, observations: [VNRecognizedTextObservation]) {
    let crosshairX = cgImage.width / 2
    let crosshairY = cgImage.height / 2
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    var bounds = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    image.draw(at: .zero)

    context?.setStrokeColor(UIColor.red.cgColor)
    context?.setLineWidth(2)

    observations.forEach { observation in
        var boundingBox = observation.boundingBox
        var fixedBoundingBox = convert(boundingBox: boundingBox, to: bounds)

        let scaledRect = VNImageRectForNormalizedRect(fixedBoundingBox, Int(size.width), Int(size.height))
        context?.addRect(fixedBoundingBox)
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
}

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
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        var bounds = CGRect(origin: .zero, size: size)
        let observations = request.results as? [VNRecognizedTextObservation]
        drawAnnotations(image: image, cgImage: cgImage, observations: observations ?? [])

        let recognizedStrings = observations?.compactMap { observation in
            var boundingBox = observation.boundingBox
            var fixedBoundingBox = convert(boundingBox: boundingBox, to: bounds)

            if fixedBoundingBox.contains(CGPoint(x: crosshairX, y: crosshairY)) {
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
