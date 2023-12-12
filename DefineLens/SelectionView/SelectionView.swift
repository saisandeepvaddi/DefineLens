//
//  SelectionView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/10/23.
//

import SwiftUI

struct SelectionView: View {
    @State var items: [CustomRecognizedText] = []
    @State var imageBuffer: CVImageBuffer?

    @GestureState private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0

    private var uiImage: UIImage? {
        guard let imageBuffer = imageBuffer else {
            print("No image buffer")
            return nil
        }
        return imageFromBuffer(imageBuffer: imageBuffer)
    }

    var body: some View {
        if let uiImage = uiImage {
            GeometryReader { geometry in
                var _ = print("image orientation: \(uiImage.imageOrientation)")
                let transformed: [CustomRecognizedText] = self.items.map { item in
                    var newItem = CustomRecognizedText(text: item.text, boundingBox: item.boundingBox)
                    newItem.boundingBox = transformBoundingBox(item.boundingBox, for: uiImage.size, in: geometry.size, orientation: uiImage.imageOrientation)
                    return newItem
                }

                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        BoundingBoxes(boxes: transformed)
                    )
            }
            .ignoresSafeArea(.all)
        } else {
            Text("No image found")
        }
    }
}

extension CGSize {
    func scale(fitting otherSize: CGSize) -> CGSize {
        let widthScale = self.width / otherSize.width
        let heightScale = self.height / otherSize.width
        return CGSize(width: widthScale, height: heightScale)
    }
}
