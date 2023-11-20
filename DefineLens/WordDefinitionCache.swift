//
//  WordDefinitionCache.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

class WordDefinitionCache {
    static let shared = WordDefinitionCache()
    private var cache: [String: String] = [:]

    private init() {}

    func definition(for word: String) -> String? {
        return cache[word]
    }

    func setDefinition(_ definition: String, for word: String) {
        cache[word] = definition
    }
}
