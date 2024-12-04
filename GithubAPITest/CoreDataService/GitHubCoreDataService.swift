//
//  CoreDataService.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation
import CoreData

/// Demonstrates using CoreData to store and retrieve fetched GitHub users when offline
struct GitHubCoreDataService {
    
    /// Saves retrieved users to device cache
    /// - Parameter gitUsers: The list of usernames to save to device
    public func saveGitUsersToCache(gitUsers: [GitUser]) {
        let context = PersistenceController.shared.container.viewContext
        
        // Fetch existing users from CoreData to check for duplicates
        let fetchRequest: NSFetchRequest<CDGitUser> = CDGitUser.fetchRequest()
        
        gitUsers.forEach { gitUser in
            // Add predicate to check if the user already exists in CoreData
            fetchRequest.predicate = NSPredicate(format: "id == %d", gitUser.id)
            
            do {
                let existingUsers = try context.fetch(fetchRequest)
                
                if let existingUser = existingUsers.first {
                    // Update existing user's properties
                    existingUser.login = gitUser.login
                    existingUser.avatarUrl = gitUser.avatarUrl
                    existingUser.reposCount = Int32(gitUser.reposCount ?? 0)
                } else {
                    // Create a new CoreData entity
                    let newUser = CDGitUser(context: context)
                    newUser.id = Int32(gitUser.id)
                    newUser.login = gitUser.login
                    newUser.avatarUrl = gitUser.avatarUrl
                    newUser.reposCount = Int32(gitUser.reposCount ?? 0)
                }
            } catch {
                print("Error searching for existing user: \(error)")
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving to cache: \(error)")
        }
    }
    
    /// Loads cached users from the device
    /// - Returns: An array of matching `GitUser` objects.
    public func loadGitUsersFromCache() -> [GitUser]? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CDGitUser> = CDGitUser.fetchRequest()
        do {
            let cdGitUsers = try context.fetch(fetchRequest)
            return cdGitUsers.map { GitUser(from: $0) }
        } catch {
            print("Error loading from cache: \(error)")
            return nil
        }
    }
    
    /// Search for users with a username matching the given query.
    /// - Parameter username: The username to search for.
    /// - Returns: An array of matching `GitUser` objects.
    func searchUsersByUsername(username: String) -> [GitUser] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CDGitUser> = CDGitUser.fetchRequest()
       
        // Add predicate to filter by username
        fetchRequest.predicate = NSPredicate(format: "login CONTAINS[cd] %@", username)
       
        do {
            // Fetch matching entities from CoreData
            let cdGitUsers = try context.fetch(fetchRequest)
            return cdGitUsers.map { GitUser(from: $0) }
        } catch {
            print("Error fetching users by username: \(error)")
            return []
        }
    }
}
