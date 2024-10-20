//
//  FeedPage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct FeedPage: View {
  @EnvironmentObject private var store: Store
  @State private var posts = Response([Post]())
  
  var body: some View {
    LoadableData(data: posts) {
      ScrollView {
        LazyVStack {
          ForEach($posts.data) { post in
            PostView(post: post)
            Divider()
              .padding(.vertical)
          }
        }
        .padding()
      }
    }
    .navigationTitle("Feed")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { ProfileLinkView() }
    .task { await fetchPosts() }
  }
  
  func fetchPosts() async {
    await posts.call("Failed to load posts") {
      try await NetworkManager.shared.fetchPosts()
    }
  }
}

#Preview {
  FeedPage()
}
