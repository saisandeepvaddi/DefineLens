//
//  AppState.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import Foundation

struct CustomRecognizedText {
    var text: String
    var boundingBox: CGRect
}

enum Modes: String, CaseIterable {
    case photo = "Photo"
    case video = "Video"
}

class AppState: ObservableObject {
    @Published var recognizedTexts: [CustomRecognizedText]?
    @Published var capturedWord: String?
    @Published var mode: Modes = .photo
    @Published var boundingBoxes: [CGRect] = []
}
