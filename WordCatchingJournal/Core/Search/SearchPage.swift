//
//  SearchPage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/28/24.
//

import SwiftUI

struct SearchPage: View {
  @EnvironmentObject private var store: Store
  @State private var results = Response(([User](), [Post]()))
  @State private var search = ""
  @State private var filter = [String]()
  @State private var searchTimer: Timer?
  
  var body: some View {
    ScrollView {
      LoadableData(data: results) {
        VStack {
          LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(results.data.0) { user in
              UserView(username: user.username, profilePic: user.profilePic)
                .onTapGesture { store.openProfile(id: user.id, username: user.username, profilePic: user.profilePic) }
            }
          }
          Divider()
          LazyVStack {
            ForEach($results.data.1) { post in
              PostView(post: post)
              Divider()
            }
          }
          .padding()
        }
      }
    }
    .searchable(text: $search)
    .navigationTitle("Search")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { ProfileLinkView() }
    .onChange(of: search) { fetchSearchResults($1) }
  }
  
  func fetchSearchResults(_ search: String) {
    searchTimer?.invalidate()
    if search.count == 0 { return }
    searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
      Task {
        await results.call("Failed to load results for \(search)") {
          try await NetworkManager.shared.fetchSearchResults(search: search)
        }
      }
    }
  }
}

fileprivate struct UserView: View {
  let username: String
  let profilePic: String?
  
  var body: some View {
    VStack {
      ProfilePic(username: username, profilePic: profilePic)
      Text(username)
    }
  }
}

#Preview {
  SearchPage()
}
