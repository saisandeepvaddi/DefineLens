//
//  DictionaryResponse.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/20/23.
//

import Foundation

struct DictionaryEntry: Decodable {
    let word: String
    let meanings: [Meaning]
}

struct Meaning: Decodable {
    let partOfSpeech: String
    let definitions: [Definition]
}

struct Definition: Decodable {
    let definition: String
}

enum DictionaryResponse {
    static func parse(jsonData: Data) -> [DictionaryEntry]? {
        do {
            let decodedData = try JSONDecoder().decode([DictionaryEntry].self, from: jsonData)
            return decodedData
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
