//
//  GitUser 2.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation

struct GitRepo: GitSearchResult, Codable, Identifiable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id
    }
}

