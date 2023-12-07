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
        List {
            ForEach(wordList, id: \.self.text) { w in
                NavigationLink(destination: DefinitionView(word: w.text)) {
                    Text(w.text)
                }
            }
        }
    }
}

#Preview {
    WordList(wordList: [])
}
