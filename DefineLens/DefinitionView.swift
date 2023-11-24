//
//  DefinitionView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import SwiftUI

struct DefinitionView: View {
    var word: String?
    @State private var isLoading: Bool = false
    @State private var definition: String = ""
    var body: some View {
        Group {
            if isLoading {
                Text("Loading...")
            } else {
                Text(definition)
            }
        }.task {
            guard let word = word else {
                print("No word yet")
                return
            }
            fetchFormattedDefinition(for: word) { def, _ in
                if let def = def {
                    definition = def
                    return
                } else {
                    definition = "Definition not found.."
                }
            }
        }
    }
}
