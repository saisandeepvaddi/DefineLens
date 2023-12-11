//
//  TouchBoundingBoxes.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/10/23.
//

import SwiftUI
struct TouchBoundingBoxes: View {
    var boxes: [CustomRecognizedText]
    var imageSize: CGSize
    var viewSize: CGSize
    var imageOrientation: UIImage.Orientation

    var body: some View {
        ForEach(boxes, id: \.text) { box in
            let transformedBox = self.transformRect(box.boundingBox)
            Rectangle()
                .frame(width: transformedBox.width, height: transformedBox.height)
                .offset(x: transformedBox.origin.x, y: transformedBox.origin.y)
                .border(Color.red, width: 2) // Use border for clear visibility
        }
    }

    private func transformRect(_ rect: CGRect) -> CGRect {
        // Calculate scale and adjust rect for the scale
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)

        // Adjust for orientation
        var adjustedRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)

        // Adjust for the aspect ratio fit
        let offsetX = (viewSize.width - imageSize.width * scale) / 2
        let offsetY = (viewSize.height - imageSize.height * scale) / 2
        adjustedRect = adjustedRect.offsetBy(dx: offsetX, dy: offsetY)

        return adjustedRect
    }
}
