//
//  DictionaryAPI.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import Foundation

func fetchDefinition(for word: String, completion: @escaping (String?) -> Void) {
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

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])

            let definition = String(data: data, encoding: .utf8)
            completion(definition)
        } catch {
            completion(nil)
        }
    }
    task.resume()
}
