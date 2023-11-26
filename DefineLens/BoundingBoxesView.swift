//
//  BoundingBoxesView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

// BoundingBoxesView.swift

import SwiftUI
import Vision

struct BoundingBoxesView: UIViewRepresentable {
    var observations: [VNRecognizedTextObservation]
    var previewLayer: CALayer

    func makeUIView(context: Context) -> UIView {
        let boundingBoxView = UIView(frame: previewLayer.frame)
        boundingBoxView.layer.addSublayer(previewLayer)
        return boundingBoxView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.sublayers?.removeSubrange(1...)

        let drawingLayer = CALayer()
        drawingLayer.frame = uiView.bounds
        uiView.layer.addSublayer(drawingLayer)

        for observation in observations {
            let boundingBox = observation.boundingBox
            let transformedBox = transformBoundingBox(boundingBox, for: drawingLayer)

            drawBoundingBox(transformedBox, on: drawingLayer)
        }
    }

    private func transformBoundingBox(_ boundingBox: CGRect, for layer: CALayer) -> CGRect {
        var transform = CGAffineTransform.identity

        transform = transform.scaledBy(x: layer.bounds.width, y: -layer.bounds.height)
        transform = transform.translatedBy(x: 0, y: -1)

        return boundingBox.applying(transform)
    }

    private func drawBoundingBox(_ rect: CGRect, on layer: CALayer) {
        let boxLayer = CAShapeLayer()
        boxLayer.frame = rect
        boxLayer.borderColor = UIColor.red.cgColor
        boxLayer.borderWidth = 2.0
        layer.addSublayer(boxLayer)
    }

    private func createBoundingBoxView(frame: CGRect) -> UIView {
        let boxView = UIView(frame: frame)
        boxView.layer.borderColor = UIColor.red.cgColor
        boxView.layer.borderWidth = 2
        return boxView
    }
}
