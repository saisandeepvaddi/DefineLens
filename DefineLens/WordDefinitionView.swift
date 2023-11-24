//
//  WordDefinitionView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/23/23.
//

import Foundation
import SwiftUI

struct WordDefinitionView: View {
    let word: String?
    let wordDefinitions: [WordDefinition]

    var body: some View {
        NavigationView {
            if wordDefinitions.count == 0 {
                VStack {
                    if let word = word {
                        Text(word).font(.headline)
                        Text("No Definition found")
                    } else {
                        Text("No words found")
                    }
                }
            } else {
                List(wordDefinitions, id: \.word) { wordDefinition in
                    Section(header: Text(wordDefinition.word).font(.headline)) {
                        ForEach(wordDefinition.phonetics, id: \.self.text) { phonetic in
                            if let text = phonetic.text {
                                Text("Pronunciation: \(text)")
                            }
                        }
                        ForEach(wordDefinition.meanings, id: \.partOfSpeech) { meaning in
                            Text(meaning.partOfSpeech).font(.subheadline)
                            ForEach(meaning.definitions, id: \.definition) { definition in
                                VStack(alignment: .leading) {
                                    Text(definition.definition)
                                    if let example = definition.example {
                                        Text("Example: \(example)").font(.caption).foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Word Definitions")
            }
        }
    }
}
