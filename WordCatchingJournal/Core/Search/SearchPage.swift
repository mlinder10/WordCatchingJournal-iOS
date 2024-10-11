//
//  SearchPage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/28/24.
//

import SwiftUI

struct SearchPage: View {
  @State private var results = Response(NetworkManager.SearchResults())
  @State private var search = ""
  @State private var filter = [String]()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LoadableData(data: results) {
          LazyVStack {
            ForEach(results.data.users) { user in
              Text(user.username)
            }
            ForEach($results.data.posts) { post in
              PostView(post: post)
            }
          }
        }
      }
      .searchable(text: $search)
    }
    .onChange(of: search, fetchSearchResults)
  }
  
  func fetchSearchResults() {
    // TODO: impliment debounce
    Task {
      await results.fetch {
        try await NetworkManager.shared.fetchSearchResults(search: self.search)
      }
    }
  }
}

#Preview {
  SearchPage()
}
