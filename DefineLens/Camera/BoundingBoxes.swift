//
//  BoundingBoxes.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/1/23.
//

import SwiftUI

struct BoundingBoxes: View {
    @State var boxes: [CustomRecognizedText] = []
    var body: some View {
        ZStack {
            ForEach(0 ..< boxes.count, id: \.self) { index in
                Path { path in
                    let box = boxes[index].boundingBox
                    path.addRect(box)
                }
                .stroke(Color.red, lineWidth: 2)
            }
        }
    }
}
