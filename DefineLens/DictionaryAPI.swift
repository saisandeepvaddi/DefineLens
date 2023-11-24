//
//  DictionaryAPI.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import Foundation

func fetchDefinition(for word: String, completion: @escaping (Data?) -> Void) {
    let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        completion(data)
    }
    task.resume()
}

func cleanUpWord(_ word: String) -> String {
    let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
    let filteredCharacters = word.unicodeScalars.filter(allowedCharacters.contains)
    return String(String.UnicodeScalarView(filteredCharacters))
}

func fetchFormattedDefinition(for word: String, completion: @escaping (String?, String?) -> Void) {
    fetchDefinition(for: cleanUpWord(word)) { jsonData in
        guard let jsonData = jsonData,
              let dictionaryEntries = DictionaryResponse.parse(jsonData: jsonData),
              let firstEntry = dictionaryEntries.first,
              let firstMeaning = firstEntry.meanings.first,
              let firstDefinition = firstMeaning.definitions.first
        else {
            print("Unable to parse definition for \(word)")
            completion(nil, "Unable to parse definition for \(word)")
            return
        }

        let formattedText = "\(word.uppercased()) (\(firstMeaning.partOfSpeech))\n\(firstDefinition.definition)"

        completion(formattedText, nil)
    }
}
