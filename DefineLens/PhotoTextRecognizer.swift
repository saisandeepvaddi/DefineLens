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
func convertBoundingBoxCoordinates(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
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

func drawAnnotationsAtObservations(image: UIImage, cgImage: CGImage, observations: [VNRecognizedTextObservation]) {
    let crosshairX = cgImage.width / 2
    let crosshairY = cgImage.height / 2
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let bounds = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    image.draw(at: .zero)

    context?.setStrokeColor(UIColor.red.cgColor)
    context?.setLineWidth(2)

    observations.forEach { observation in
        let boundingBox = observation.boundingBox
        let fixedBoundingBox = convertBoundingBoxCoordinates(boundingBox: boundingBox, to: bounds)

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

func drawAnnotationsAtBoxes(image: UIImage, cgImage: CGImage, bboxes: [CGRect]) {
    let crosshairX = cgImage.width / 2
    let crosshairY = cgImage.height / 2
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let bounds = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    image.draw(at: .zero)

    context?.setStrokeColor(UIColor.red.cgColor)
    context?.setLineWidth(2)

    bboxes.forEach { bbox in
        context?.addRect(bbox)
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
        let bounds = CGRect(origin: .zero, size: size)
        let observations = request.results as? [VNRecognizedTextObservation]
//        drawAnnotationsAtObservations(image: image, cgImage: cgImage, observations: observations ?? [])
        guard let observations = observations else {
            completion(nil)
            return
        }

        var recognizedStrings = [String]()
        var bboxes = [CGRect]()
        let crosshairPoint = CGPoint(x: crosshairX, y: crosshairY)

        for observation in observations {
            let boundingBox = observation.boundingBox
            let fixedBoundingBox = convertBoundingBoxCoordinates(boundingBox: boundingBox, to: bounds)

            if fixedBoundingBox.contains(CGPoint(x: crosshairX, y: crosshairY)) {
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
                            let wordBoundingBoxTransformed = convertBoundingBoxCoordinates(boundingBox: wordBoundingBox, to: bounds)
                            bboxes.append(wordBoundingBoxTransformed)
                            if wordBoundingBoxTransformed.contains(crosshairPoint) {
                                recognizedStrings.append(word)
                            }
                        } catch {
                            print("Error in wordRange")
                        }
                    }
                }
            }
        }

        drawAnnotationsAtBoxes(image: image, cgImage: cgImage, bboxes: bboxes)

        if recognizedStrings.count == 0 {
            print("No words found")
        }

        let combinedText = recognizedStrings.joined(separator: "\n")
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
