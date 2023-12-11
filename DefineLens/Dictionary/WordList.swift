//
//  WordList.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/6/23.
//

import SwiftUI

struct WordList: View {
    @State var wordList: [CustomRecognizedText] = []
    var body: some View {
        let wordTexts = wordList.map { $0.text }
        let uniqueWords = sortCleanUniqueWords(words: wordTexts)
        List {
            ForEach(uniqueWords, id: \.self) { word in
                NavigationLink(destination: DefinitionView(word: word)) {
                    Text(word)
                }
            }
        }
    }
}
