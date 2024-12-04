//
//  APIServiceConstants.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//

import Foundation

enum APIConstants {
    static let useCombine = false
    static let host = "https://api.github.com"
    static let searchPath = "/search"
    static let usersPath = "/users"
    static let reposPath = "/repositories"
    
    static let queryString = "q"
    static let repoQueryString = "user:"
    
    static let acceptHeaderKey = "Accept"
    static let acceptHeaderValue = "application/vnd.github+json"
    static let apiVersionKey = "X-GitHub-Api-Version"
    static let apiVersion = "2022-11-28"
    static let authHeaderKey = "Authorization"
    static let authHeader = "Bearer "
    
    static let rateLimitHeader = "x-ratelimit-limit"
    static let rateLimitRemainingHeader = "x-ratelimit-remaining"
}

enum APIErrors: Error {
    case invalidRequest
    case invalidReponse
    case rateLimitExceeded
    case unauthorized
    case noInternet
    
    var stringVal: String {
        switch self {
        case .invalidRequest:
            "Invalid Search string"
        case .invalidReponse:
            "Unable to decode response from server."
        case .rateLimitExceeded:
            "Rate Limit Exceeded. Please refresh Authorization Token."
        case .unauthorized:
            "Unauthorized access. Please refresh Authorization Token."
        case .noInternet:
            "No Internet Connection. Using Cached Data."
        }
    }
}

