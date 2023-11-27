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

class AppState: ObservableObject {
    @Published var word: String?
    @Published var recognizedTexts: [CustomRecognizedText]?
}
