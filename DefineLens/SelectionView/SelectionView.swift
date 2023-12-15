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

    @State private var selectableItems: [SelectableText] = []
    @StateObject private var selectionManager = TextSelectionManager()

    @GestureState private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var geometrySize: CGSize = .zero
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

                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        BoundingBoxes(selectableTexts: self.$selectableItems, selectionManager: self.selectionManager)
                    )
                    .onAppear {
                        self.geometrySize = geometry.size
                    }
            }
            .onAppear {
                self.updateSelectableItems(with: self.items, size: uiImage.size)
            }
            .ignoresSafeArea(.all)
        } else {
            Text("No image found")
        }
    }

    private func updateSelectableItems(with items: [CustomRecognizedText], size: CGSize) {
        self.selectableItems = self.items.map { item in
            var newItem = CustomRecognizedText(text: item.text, boundingBox: item.boundingBox)
            newItem.boundingBox = transformBoundingBox(item.boundingBox, for: size, in: self.geometrySize)

            return SelectableText(original: newItem, isSelected: false)
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
