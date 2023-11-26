//
//  DefinitionView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import SwiftUI

struct DefinitionView: View {
    @State var word: String?
    @State private var isLoading: Bool = true
    @State private var definitions = [WordDefinition]()
    var body: some View {
        Group {
            if isLoading {
                if let word = word, word.count > 0 {
                    Text(word).font(.headline)
                }
                ProgressView()
            } else {
                WordDefinitionView(word: word, wordDefinitions: definitions)
            }
        }.task {
            guard let word = word else {
                print("No word yet")
                return
            }
            isLoading = true
            fetchFormattedDefinition(for: word) { def, _ in
                if let def = def {
                    definitions = def
                } else {
                    print("No definitions found")
                    definitions = []
                }
                isLoading = false
            }
        }
    }
}
