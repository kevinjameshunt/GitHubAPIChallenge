//
//  CharacterRowView.swift
//  GithubAPITest
//
//  Created by Kevin Hunt on 2024-11-28.
//

import SwiftUI

struct GitHubUserRowView: View {
    enum Constants {
        static let thumbWidthHeight: CGFloat = 100.0
        static let reposCountText = "Repos Count:"
    }
    
    let gitUser: GitUser
    
    var body: some View {
        HStack() {
            AsyncImage(url: URL(string:gitUser.avatarUrl)) { phase in
                if let image = phase.image {
                    image.resizable().frame(width: Constants.thumbWidthHeight, height: Constants.thumbWidthHeight)
                } else if phase.error != nil {
                    // Indicates an error.
                    Color.red.frame(width: Constants.thumbWidthHeight, height: Constants.thumbWidthHeight)
                } else {
                    // Acts as a placeholder.
                    Color.clear.frame(width: Constants.thumbWidthHeight, height: Constants.thumbWidthHeight)
                }
            }
            VStack(alignment: .leading) {
                Text(gitUser.login).bold()
                Text("\(Constants.reposCountText) \(gitUser.reposCount ?? 0)")
                Spacer()
            }
        }
        .padding()
    }
}

struct GitHubUserRowView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubUserRowView(gitUser: GitUser(id: 1, login: "Testuser", avatarUrl: ""))
    }
}
