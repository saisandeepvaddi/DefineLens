//
//  DictionaryResponse.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/20/23.
//

import Foundation

// WordDefinitionParser.swift

import Foundation

struct WordDefinition: Codable {
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let license: License
    let sourceUrls: [String]

    struct Phonetic: Codable {
        let audio: String?
        let sourceUrl: String?
        let license: License?
        let text: String?
    }

    struct Meaning: Codable {
        let partOfSpeech: String
        let definitions: [Definition]
        let synonyms: [String]
        let antonyms: [String]
    }

    struct Definition: Codable {
        let definition: String
        let synonyms: [String]
        let antonyms: [String]
        let example: String?
    }

    struct License: Codable {
        let name: String
        let url: String
    }
}

func parse(from jsonData: Data) -> [WordDefinition]? {
    let decoder = JSONDecoder()
    do {
        let wordDefinitions = try decoder.decode([WordDefinition].self, from: jsonData)
        return wordDefinitions
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}
