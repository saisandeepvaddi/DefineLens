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

    private var uiImage: UIImage? {
        guard let imageBuffer = imageBuffer else {
            print("No image buffer")
            return nil
        }
        return uiImageFromCVImageBuffer(imageBuffer: imageBuffer)
    }

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
            } else {
                Text("No image found")
            }
        }
        .frame(width: 300, height: 400)
        .padding()
    }
}
