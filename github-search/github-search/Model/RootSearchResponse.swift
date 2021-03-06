//
//  RootSearchResult.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 27.12.2021.
//

import Foundation

struct RootSearchResponse: Codable {
    let totalCount: Int
    let items: [RepositoryResponse]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items = "items"
    }
}
