//
//  TextRecognizer.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/23/23.
//

import Foundation
import UIKit
import Vision

func createTextDetectionRequest(image: UIImage, completion: @escaping (String?) -> Void) -> VNRecognizeTextRequest {
    let request = VNRecognizeTextRequest { request, error in
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
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
    return request
}
