//
//  GeometryUtils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/26/23.
//

import SwiftUI

//// From: https://stackoverflow.com/a/73399681/7376662
func transformBoundingBox(_ boundingBox: CGRect, for bounds: CGRect) -> CGRect {
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

// An alternative to above function
// func transformBoundingBox(_ boundingBox: CGRect, for bounds: CGRect) -> CGRect {
//    var transform = CGAffineTransform.identity
//    transform = transform.scaledBy(x: bounds.width, y: -bounds.height)
//    transform = transform.translatedBy(x: 0, y: -1)
//
//    return boundingBox.applying(transform)
// }

func drawBoundingBox(_ rect: CGRect, on layer: CALayer) {
    let boxLayer = CAShapeLayer()
    boxLayer.frame = rect
    boxLayer.borderColor = UIColor.red.cgColor
    boxLayer.borderWidth = 2.0
    layer.addSublayer(boxLayer)
}

func createBoundingBoxView(frame: CGRect) -> UIView {
    let boxView = UIView(frame: frame)
    boxView.layer.borderColor = UIColor.red.cgColor
    boxView.layer.borderWidth = 2
    return boxView
}
