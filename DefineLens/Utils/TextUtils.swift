//
//  TextUtils.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/6/23.
//

import Foundation

extension String {
    func removingSpecialCharacters() -> String {
        return String(self.filter { !" `~!@#$%^&*()-_+={}[]|\\:;'<>,.?/\"".contains($0) })
    }
}

func cleanUpWord(word: String) -> String {
    return word.trimmingCharacters(in: .whitespacesAndNewlines)
        .removingSpecialCharacters()
        .capitalized
}

func sortCleanUniqueWords(words: [String]) -> [String] {
    return words.map { cleanUpWord(word: $0) }.removingDuplicates()
        .sorted { $0.lowercased() < $1.lowercased() }
}

func cleanAndUniqueWords(words: [String]) -> [String] {
    return words.map { cleanUpWord(word: $0) }
        .removingDuplicates()
}

extension Collection where Element: Hashable {
    func removingDuplicates() -> [Element] {
        return Array(Set(self))
    }
}
