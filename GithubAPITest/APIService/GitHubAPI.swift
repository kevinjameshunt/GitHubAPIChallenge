//
//  GitHubAPI.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation

// The API endpoint and the paths to them should be constructed here where possible

enum GitHubAPI {
    case users(queryString: String)
    case repos(username: String)
    
    var url: URL? {
        var components = URLComponents(string: self.host)
        components?.path = self.path
        components?.queryItems = self.queryItems
        return components?.url
    }
    
    var host: String {
        return APIConstants.host
    }
    
    var path: String {
        switch self {
        case .users:
            return APIConstants.searchPath + APIConstants.usersPath
        case .repos:
            return APIConstants.searchPath + APIConstants.reposPath
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .users(let queryString):
            return [
                URLQueryItem(name: APIConstants.queryString, value: queryString),
            ]
        case .repos(let queryString):
            return [
                URLQueryItem(name: APIConstants.queryString, value: APIConstants.repoQueryString + queryString),
            ]
        }
    }
    
    

}
