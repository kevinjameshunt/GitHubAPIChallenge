//
//  ContentView.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var viewModel: GitUsersListViewModel
    @State private var showingAlert = false
    @State private var searchText: String = "Kevin"

    init() {
        let coreDataService = GitHubCoreDataService()
        let apiService = GitHubAPIService(coreDataService: coreDataService)
        _viewModel = StateObject(wrappedValue: GitUsersListViewModel(apiService: apiService, coreDataService: coreDataService))
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Username", text: $searchText)
                    .padding()
                Button("Search") {
                    Task {
                        viewModel.gitUsers = await viewModel.searchUsers(nameContains: searchText, shouldCache: true)
                    }
                }
                .padding()
            }
            List(viewModel.gitUsers) { gitUser in
                GitHubUserRowView(gitUser: gitUser)
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText)
            .onAppear {
                viewModel.loadChache()
            }
            .task {
                viewModel.gitUsers = await viewModel.searchUsers(nameContains: searchText, shouldCache: true)
            }
            HStack {
                TextField("Auth Token", text: $viewModel.authToken)
                    .padding()
            }
        }
        .onChange(of: viewModel.errorMessage) {
            if viewModel.errorMessage != "" {
                showingAlert = true
            } else {
                showingAlert = false
            }
        }
        .alert(viewModel.errorMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = ""
                Task {
                    await viewModel.fetchFromChache(nameContains: searchText)
                }
            }
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
