//
//  GitHubTrendingAPI.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/7/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import Foundation
import Combine

enum TimeRange : String, CaseIterable {
    case daily
    case weekly
    case monthly
}

enum Language : String, CaseIterable {
    case go
    case swift
    case javascript
}

enum GitHubTrendingAPI {
    static let baseURLComponents = URLComponents(
        string: "https://github-trending-api.now.sh/repositories"
    )!

    static func fetchTrendingItems(
        for language: Language,
        in timeRange: TimeRange
    ) -> Future<[GitHubTrendingItem], URLError> {
        return Future  { completion in
            var components = baseURLComponents
            components.queryItems = [
                URLQueryItem(name: "language", value: language.rawValue),
                URLQueryItem(name: "since", value: timeRange.rawValue),
            ]

            guard let url = components.url else {
                fatalError()
            }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error as! URLError))
                } else if let data = data {
                    do {
                        let items = try JSONDecoder().decode([GitHubTrendingItem].self, from: data)
                        completion(.success(items))
                    } catch let decodingError {
                        let error = URLError(.badServerResponse, userInfo: [NSUnderlyingErrorKey : decodingError])
                        completion(.failure(error))
                    }
                } else {
                    completion(.success([]))
                }
            }.resume()
        }
    }
}

struct GitHubTrendingItem {
    var author: String
    var name: String
    var avatar: URL? = nil
    var description: String
    var url: URL
    var language: String? = nil
    var languageColor: String? = nil
    var stars: Int = 0
    var forks: Int = 0
}

extension GitHubTrendingItem : Decodable {
    enum CodingKeys : CodingKey {
        case author
        case name
        case avatar
        case description
        case url
        case language
        case languageColor
        case stars
        case forks
    }
}
