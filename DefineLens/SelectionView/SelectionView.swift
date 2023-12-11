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
            GeometryReader { _ in
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            BoundingBoxes(boxes: self.items)
                        )
                }
            }
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
