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
    var name: String
    var state: ViewState = .new
    
    enum CodingKeys: String, CodingKey {
        case url = "html_url"
        case stars = "stargazers_count"
        case name = "name"
    }
}
