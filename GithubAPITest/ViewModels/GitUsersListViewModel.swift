//
//  GitUsersListViewModel.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation

/// For retrieving and managing a list of GitUsers
class GitUsersListViewModel: ObservableObject {
    enum Constants {
        static let sortedBy: String = "name"
    }
    
    @Published var authToken: String = ""
    @Published var errorMessage = ""
    @Published var gitUsers: [GitUser] = []
    @Published var searchText: String = "" {
        didSet {
            Task {
                let gitUsers = await self.searchUsers(nameContains: searchText, shouldCache: false)
                await MainActor.run { self.gitUsers = gitUsers }
            }
        }
    }
    
    @Published var apiService: GitHubAPIService
    let coreDataService: GitHubCoreDataService

    init(apiService: GitHubAPIService, coreDataService: GitHubCoreDataService) {
        self.apiService = apiService
        self.coreDataService = coreDataService
    }
    
    /// Searches for users with a given string
    /// - Parameters:
    ///   - nameContains: search string the username should contain
    ///   - shouldCache: if the results should be cacued
    /// - Returns: a list of GitUser objects
    func searchUsers(nameContains: String, shouldCache: Bool) async  -> [GitUser] {
        do  {
            let users = try await self.apiService.fetchUsers(nameContains: nameContains, shouldCache: shouldCache, authToken: authToken)
            return users
        } catch {
            if let error = error as? APIErrors {
                switch error {
                case .noInternet:
                    await self.fetchFromChache(nameContains: nameContains)
                default:
                    await MainActor.run { errorMessage = error.stringVal }
                    await self.fetchFromChache(nameContains: nameContains)
                }
            }
            return []
        }
    }
    
    /// Loads cached Gituser objects previously stored on the device
    func loadChache() {
        guard let userCache = self.coreDataService.loadGitUsersFromCache() else {
            return
        }
        self.gitUsers = userCache
    }
    
    /// Searches for cached Gituser objects previously stored on the device
    /// - Parameters:
    ///   - nameContains: search string the username should contain
    func fetchFromChache(nameContains: String) async {
        guard let userCache = self.coreDataService.loadGitUsersFromCache() else {
            return
        }
        await MainActor.run { self.gitUsers = userCache }
    }
}
