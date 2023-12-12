//
//  GeometryUtils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/26/23.
//

import AVFoundation
import SwiftUI

//// From: https://stackoverflow.com/a/73399681/7376662
// func transformBoundingBox(_ boundingBox: CGRect, for bounds: CGRect) -> CGRect {
//    let imageWidth = bounds.width
//    let imageHeight = bounds.height
//
//    // Begin with input rect.
//    var rect = boundingBox
//
//    // Reposition origin.
//    rect.origin.x *= imageWidth
//    rect.origin.x += bounds.minX
//    rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY
//
//    // Rescale normalized coordinates.
//    rect.size.width *= imageWidth
//    rect.size.height *= imageHeight
//
//    return rect
// }

func transformBoundingBox(_ boundingBox: CGRect, for imageBounds: CGRect) -> CGRect {
    // Flip Y coordinate
    let flippedY = 1 - boundingBox.origin.y - boundingBox.height
    let transformedRect = CGRect(x: boundingBox.origin.x * imageBounds.width,
                                 y: flippedY * imageBounds.height,
                                 width: boundingBox.width * imageBounds.width,
                                 height: boundingBox.height * imageBounds.height)
    return transformedRect
}

func transformBoundingBox(_ boundingBox: CGRect, for imageSize: CGSize) -> CGRect {
    let flippedY = 1 - boundingBox.origin.y - boundingBox.height
    let transformedRect = CGRect(x: boundingBox.origin.x * imageSize.width,
                                 y: flippedY * imageSize.height,
                                 width: boundingBox.width * imageSize.width,
                                 height: boundingBox.height * imageSize.height)
    return transformedRect
}

func rotateRect(_ rect: CGRect) -> CGRect {
    let x = rect.midX
    let y = rect.midY
    let transform = CGAffineTransform(translationX: x, y: y)
        .rotated(by: -.pi / 2) // Negative for clockwise rotation
        .translatedBy(x: -x, y: -y)
    return rect.applying(transform)
}

func transformBoundingBox(_ boundingBox: CGRect, for imageSize: CGSize, in viewSize: CGSize, orientation: UIImage.Orientation) -> CGRect {
    // First, we need to adjust the bounding box based on the image's orientation
    var adjustedBoundingBox = boundingBox
//    switch orientation {
//        case .right: // 90 degrees clockwise
//            adjustedBoundingBox = CGRect(
//                x: boundingBox.origin.y,
//                y: boundingBox.origin.x,
//                width: boundingBox.height,
//                height: boundingBox.width
//            )
//        case .left: // 90 degrees counter-clockwise
//            adjustedBoundingBox = CGRect(
//                x: 1 - boundingBox.origin.y - boundingBox.height,
//                y: 1 - boundingBox.origin.x - boundingBox.width,
//                width: boundingBox.height,
//                height: boundingBox.width
//            )
//        case .down: // 180 degrees
//            adjustedBoundingBox = CGRect(
//                x: 1 - boundingBox.origin.x - boundingBox.width,
//                y: 1 - boundingBox.origin.y - boundingBox.height,
//                width: boundingBox.width,
//                height: boundingBox.height
//            )
//        case .up: // No rotation
//            // No adjustment needed
//            break
//        // Add cases for mirrored orientations if necessary
//        default:
//            break
//    }

    adjustedBoundingBox.origin.y = 1 - adjustedBoundingBox.origin.y - adjustedBoundingBox.height

    // Now, continue with the aspect ratio adjustments as before
    let aspectFitRect = AVMakeRect(aspectRatio: imageSize, insideRect: CGRect(origin: .zero, size: viewSize))

    // Scale the bounding box to the aspect-fit frame
    let scaledRect = CGRect(
        x: adjustedBoundingBox.origin.x * aspectFitRect.size.width + aspectFitRect.origin.x,
        y: adjustedBoundingBox.origin.y * aspectFitRect.size.height + aspectFitRect.origin.y,
        width: adjustedBoundingBox.size.width * aspectFitRect.size.width,
        height: adjustedBoundingBox.size.height * aspectFitRect.size.height
    )

    return scaledRect
}
