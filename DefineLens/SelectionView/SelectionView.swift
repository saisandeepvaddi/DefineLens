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

    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    @State private var imageSize: CGSize = .zero

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
                    .scaleEffect(self.zoomScale)
                    .offset(self.offset)
                    .gesture(self.magnificationGesture)
                    .overlay(
                        BoundingBoxes(selectableTexts: self.$selectableItems, selectionManager: self.selectionManager, zoomScale: self.zoomScale, offset: self.offset)
//                            .scaleEffect(self.zoomScale)
                    )
                    .onAppear {
                        self.geometrySize = geometry.size
                        self.imageSize = uiImage.size
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

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.zoomScale = value
            }
            .onEnded { _ in
//                self.updateSelectableItems(with: self.items, size: self.imageSize)
            }
    }

    private func updateSelectableItems(with items: [CustomRecognizedText], size: CGSize) {
        let currentImageSize = CGSize(width: size.width * self.zoomScale, height: size.height * self.zoomScale)
        self.selectableItems = self.items.map { item in
            var newItem = CustomRecognizedText(text: item.text, boundingBox: item.boundingBox)
            newItem.boundingBox = transformBoundingBox(item.boundingBox, for: currentImageSize, in: self.geometrySize)

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
