//
//  RepositoryResponse.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 28.12.2021.
//

import Foundation

struct RepositoryResponse: Codable {
    var url: String
    var stars: Int
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case url = "html_url"
        case stars = "stargazers_count"
        case id = "id"
        case name = "name"
    }
}
