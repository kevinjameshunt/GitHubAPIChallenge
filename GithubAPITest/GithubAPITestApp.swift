//
//  GithubAPITestApp.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//

import SwiftUI

@main
struct GithubAPITestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
