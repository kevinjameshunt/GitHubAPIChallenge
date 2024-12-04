//
//  SearchData.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation

protocol GitSearchResult: Codable {
    var id: Int { get }
}

struct SearchData<T: GitSearchResult>: Codable {
    let totalCount: Int
    let items: [T]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }

}
