//
//  RepositoryResponse.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 28.12.2021.
//

import Foundation

struct RepositoryResponse: Codable {
    let url: String
    let stars: Int
    let name: String
    var state = false
    
    enum CodingKeys: String, CodingKey {
        case url = "html_url"
        case stars = "stargazers_count"
        case name = "name"
        case state = "state"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decode(String.self, forKey: .url)
        stars = try values.decode(Int.self, forKey: .stars)
        name = try values.decode(String.self, forKey: .name)
        state = (try? values.decode(Bool.self, forKey: .state)) ?? false
    }
}
