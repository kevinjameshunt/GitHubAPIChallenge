//
//  GitUser+CoreData.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//


import Foundation

extension GitUser {
    // Map CoreData cdGitUser to GitUser
    init(from cdGitUser: CDGitUser) {
        self.id = Int(cdGitUser.id)
        self.login = cdGitUser.login ?? ""
        self.avatarUrl = cdGitUser.avatarUrl ?? ""
        self.reposCount = Int(cdGitUser.reposCount)
    }
}
