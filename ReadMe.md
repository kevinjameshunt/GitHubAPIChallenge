# Mobile Engineer take home assignment 

## by Kevin James Hunt

### Project
The Interface of this app was prototyped quickly for building and testing using SwiftUI. The application uses an API service to fetch GitHub users and their repository information. In GitHubAPIService.swift are several examples of using Async/Await, including using task groups for multiple calls for the repo counts. 

Data is cached from every search and the users and repo counts are stored locally on the device. If there is an error or no network available, the app will default to search the cached versions of the data instead. 

### Dependencies
Due to the rate limit restrictions on the GitHub REST API. You will need to add your own access token to the app. 

### Future
With more time I would have liked to move the GitHubAPIService CoreDataService into Kotlin multiplatform, specifying generic protocols that would allow either the swift version of the Kotlin version to be injected into the apps. 

Additionally, setting up SSO for the app to retrieve the token would be a necessity, as having to paste our own token is not exactly user-friendly. 