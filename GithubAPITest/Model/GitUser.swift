//
//  GitUser.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//

import Foundation

struct GitUser: GitSearchResult, Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    var reposCount: Int? = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case reposCount
    }
}

