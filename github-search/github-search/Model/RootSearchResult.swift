//
//  RootSearchResult.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 27.12.2021.
//

import Foundation

struct RootSearchResult: Codable {
    var totalCount: Int
    var items: [Repository]

    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items = "items"
    }
}
