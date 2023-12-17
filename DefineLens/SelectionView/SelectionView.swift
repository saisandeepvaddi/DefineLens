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

    @State private var currentZoom: CGFloat = 0.0
    @State private var totalZoom: CGFloat = 1.0
    @State private var zoomScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero

    @State private var imageSize: CGSize = .zero

    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Angle = .zero

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
                    .scaleEffect(self.currentZoom + self.totalZoom)
                    .offset(self.offset + self.dragOffset)
//                    .rotationEffect(self.rotationAngle)
                    .gesture(self.magnificationGesture)
//                    .simultaneousGesture(self.dragGesture)
//                    .gesture(TapGesture().onEnded { value in
//                        print("value: \(value)")
//                    })
//                    .simultaneousGesture(self.rotationGesture)
                    .overlay(
                        BoundingBoxes(selectableTexts: self.$selectableItems, selectionManager: self.selectionManager, zoomScale: self.totalZoom, offset: self.offset)
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

                self.currentZoom = value.magnitude - 1
            }
            .onEnded { _ in
                self.totalZoom += self.currentZoom
                self.currentZoom = 0
                self.updateSelectableItems(with: self.items, size: self.imageSize)
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation
            }
            .onEnded { _ in
                self.offset += self.dragOffset
                self.dragOffset = .zero
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { angle in
                self.rotationAngle = angle
            }
    }

    private func updateSelectableItems(with items: [CustomRecognizedText], size: CGSize) {
        let currentImageSize = CGSize(width: size.width * self.totalZoom, height: size.height * self.totalZoom)
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

extension CGSize {
    static func += (left: inout CGSize, right: CGSize) {
        left = CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }
}
