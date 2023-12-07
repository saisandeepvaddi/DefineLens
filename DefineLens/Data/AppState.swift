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
    case single = "Single"
    case multi = "Multi"
}

class AppState: ObservableObject {
    @Published var words: [CustomRecognizedText]?
    @Published var capturedWord: String?
    @Published var mode: Modes = .single
}
