//
//  APIService.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation
import Combine

/// Generic APIService
protocol APIService {
    func fetchUsers(nameContains: String, shouldCache: Bool, authToken: String) async throws -> [GitUser]
}

/// Service for connecting to the GIthub API Endpoints
class GitHubAPIService: APIService, ObservableObject {
    @Published var userss = [GitUser]()
    let coreDataService: GitHubCoreDataService
    var cancellables = Set<AnyCancellable>()
    
    init(coreDataService: GitHubCoreDataService = GitHubCoreDataService()) {
        self.coreDataService = coreDataService
    }
    
    
    /// Fetch Users for a given name field
    /// - Parameters:
    ///   - nameContains: text to search
    ///   - shouldCache: wether or not to cache the results
    ///   - authToken: auth token required by the search
    /// - Returns: A list of GitUsers retrieved by the API
    public func fetchUsers(nameContains: String, shouldCache: Bool, authToken: String) async throws -> [GitUser] {
        guard let apiURL = getUserSearchApiUrl(nameContains: nameContains) else {
            print("Error: Invalid URL")
            throw APIErrors.invalidRequest
        }

        print("URL: \(apiURL)")
        
        let urlRequest = getRequest(url: apiURL, authToken: authToken)
        
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response \(response)")
                throw APIErrors.invalidRequest
            }
            
            // Check HTTP response status
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response status code \(response)")
                if httpResponse.statusCode == 403 {
                    throw APIErrors.unauthorized
                } else if let rateLimitRemaining = httpResponse.allHeaderFields[APIConstants.rateLimitRemainingHeader] as? Int,
                          let rateLimit = httpResponse.allHeaderFields[APIConstants.rateLimitHeader] as? Int {
                    print("rateLimitRemaining: \(rateLimitRemaining) / \(rateLimit)")
                    if rateLimitRemaining == 0 {
                        throw APIErrors.rateLimitExceeded
                    } else {
                        throw APIErrors.invalidRequest
                    }
                } else {
                    throw APIErrors.invalidRequest
                }
            }
            
            // Decode the JSON into list of userss
            let usersData = try JSONDecoder().decode(SearchData<GitUser>.self, from: data)
            guard var users = usersData.items else {
                throw APIErrors.invalidReponse
            }
            
            // Fetch repository counts for each user
            users = try await fetchAndUpdateRepoCounts(for: users, authToken: authToken)

            // Save data to cache
            if shouldCache {
                coreDataService.saveGitUsersToCache(gitUsers: users)
            }

            // Results are sorted by the query
            return users
        } catch let error as URLError where error.code == .notConnectedToInternet {
            print("Error: No internet connection")
            throw APIErrors.noInternet
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }

    
    /// Fetches repo data list of GitUsrs
    /// - Parameters:
    ///   - users: a list of GitUser objects to retrieve the repo counts
    ///   - authToken: the authToken required for the request
    /// - Returns: A list of updated GitUsers
    private func fetchAndUpdateRepoCounts(for users: [GitUser], authToken: String) async throws -> [GitUser] {
        var updatedUsers = users
        let session = URLSession.shared
        
        // Perform requests for each user's repo URL concurrently
        try await withThrowingTaskGroup(of: (GitUser, Int).self) { group in
            for user in users {
                guard let repoURL = getUserReposApiUrl(nameContains: user.login) else { continue }
                group.addTask {
                    let repoCount = try await self.fetchRepoCount(from: repoURL, session: session, authToken: authToken)
                    return (user, repoCount)
                }
            }
            
            for try await (user, repoCount) in group {
                if let index = updatedUsers.firstIndex(where: { $0.id == user.id }) {
                    updatedUsers[index].reposCount = repoCount
                }
            }
        }
        
        return updatedUsers
    }
    
    /// Fetches the repo count of a given user based on their login id
    /// - Parameters:
    ///   - url: The serach url contining the login id of the user
    ///   - session: The shared URL session for the requests
    ///   - authToken: the authToken required for the request
    /// - Returns: The count of repos for a given login
    private func fetchRepoCount(from url: URL, session: URLSession, authToken: String) async throws -> Int {
        
        let (data, response) = try await session.data(for: getRequest(url: url,authToken: authToken))
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error: Invalid response \(response)")
            throw APIErrors.invalidRequest
        }
        
        // Check HTTP response status
        guard (200...299).contains(httpResponse.statusCode) else {
            print("Error: Invalid response status code \(response)")
            if httpResponse.statusCode == 403 {
                throw APIErrors.unauthorized
            } else if let rateLimitRemaining = httpResponse.allHeaderFields[APIConstants.rateLimitRemainingHeader] as? Int,
                      let rateLimit = httpResponse.allHeaderFields[APIConstants.rateLimitHeader] as? Int {
                print("rateLimitRemaining: \(rateLimitRemaining) / \(rateLimit)")
                if rateLimitRemaining == 0 {
                    throw APIErrors.rateLimitExceeded
                } else {
                    throw APIErrors.invalidRequest
                }
            } else {
                throw APIErrors.invalidRequest
            }
        }
        
        // Decode the JSON array of repositories
        let repoData = try JSONDecoder().decode(SearchData<GitRepo>.self, from: data)
        guard let repos = repoData.items else {
            throw APIErrors.invalidReponse
        }
        return repos.count
    }

    
    private func getUserSearchApiUrl(nameContains: String) -> URL? {
        // Request the users from the API
        guard let apiURL = GitHubAPI.users(queryString: nameContains).url else {
            return nil
        }
        return apiURL
    }
    
    private func getUserReposApiUrl(nameContains: String) -> URL? {
        // Request the users from the API
        guard let apiURL = GitHubAPI.repos(username: nameContains).url else {
            return nil
        }
        return apiURL
    }
    
    private func getRequest(url: URL, authToken: String) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(APIConstants.acceptHeaderValue, forHTTPHeaderField: APIConstants.acceptHeaderKey)
        urlRequest.addValue(APIConstants.apiVersion, forHTTPHeaderField: APIConstants.apiVersionKey)
        if authToken.count > 0 {
            urlRequest.addValue("Bearer \(authToken)", forHTTPHeaderField: APIConstants.authHeaderKey)
        }
        return urlRequest
    }
}
