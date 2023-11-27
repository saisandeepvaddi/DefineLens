//
//  BoundingBoxesView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

// BoundingBoxesView.swift

import SwiftUI
import Vision

func areEqual(_ array1: [VNRecognizedTextObservation], _ array2: [VNRecognizedTextObservation]) -> Bool {
    guard array1.count == array2.count else {
        return false
    }

    for (observation1, observation2) in zip(array1, array2) {
        if observation1.boundingBox != observation2.boundingBox {
            // Modify this condition to include other properties you want to compare
            return false
        }
    }

    return true
}

struct BoundingBoxesView: UIViewRepresentable {
    var observations: [VNRecognizedTextObservation]
    var previewLayer: CALayer
    var onWordChange: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let boundingBoxView = UIView(frame: previewLayer.frame)
        boundingBoxView.layer.addSublayer(previewLayer)
        return boundingBoxView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
//        if areEqual(context.coordinator.prevObservations, observations) {
//            return
//        } else {
//            print("Not equal: \(Date.now)")
//            context.coordinator.prevObservations = observations
//        }
//        print("Updating")

        uiView.layer.sublayers?.removeSubrange(1...)

        let drawingLayer = CALayer()
        drawingLayer.frame = uiView.bounds
        uiView.layer.addSublayer(drawingLayer)

        let crosshairPosition = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

        for observation in observations {
            let boundingBox = observation.boundingBox
            let transformedBox = transformBoundingBox(boundingBox, for: drawingLayer.bounds)

//            if transformedBox.contains(crosshairPosition) {
//                guard let candidate = observation.topCandidates(1).first else { continue }
//                let fullString = candidate.string
//                let words = fullString.split(separator: " ").map(String.init)
//                for word in words {
//                    if let wordRange = fullString.range(of: word) {
//                        do {
//                            let boxObservation = try candidate.boundingBox(for: wordRange)
//                            guard let boxObservation = boxObservation else {
//                                continue
//                            }
//
//                            let wordBoundingBox = boxObservation.boundingBox
//                            let wordBoundingBoxTransformed = transformBoundingBox(
//                                wordBoundingBox, for: drawingLayer.bounds)
//
//                            if wordBoundingBoxTransformed.contains(crosshairPosition) {
//                                drawBoundingBox(wordBoundingBoxTransformed, on: drawingLayer)
//
//                                DispatchQueue.main.async {
//                                    onWordChange(word)
//                                }
//                            }
//                        } catch {
//                            print("Error in wordRange")
//                        }
//                    }
//                }
//            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator {
        var prevObservations: [VNRecognizedTextObservation] = []
    }
}
