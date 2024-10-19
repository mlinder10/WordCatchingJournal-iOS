//
//  PostView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct PostView: View {
  @EnvironmentObject private var store: Store
  @Binding var post: Post
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      userLinkHeader
      Text(post.word.capitalized)
        .fontWeight(.semibold)
      Text(post.definition)
      Text(post.partOfSpeech.capitalized)
        .foregroundStyle(.secondary)
        .font(.caption)
        .italic()
      HStack {
        HStack {
          Image(systemName: post.liked == 1 ? "heart.fill" : "heart")
            .foregroundStyle(post.liked == 1 ? .red : .secondary)
          Text("\(post.likesCount) \(post.likesCount == 1 ? "Like" : "Likes")")
        }
        .onTapGesture { handleLike() }
        HStack {
          Image(systemName: post.favorited == 1 ? "star.fill" : "star")
            .foregroundStyle(post.favorited == 1 ? .yellow : .secondary)
          Text("\(post.favoritesCount) \(post.favoritesCount == 1 ? "Favorite" : "Favorites")")
        }
        .onTapGesture { handleFavorite() }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }
  
  private var userLinkHeader: some View {
    HStack {
      ProfilePic(username: post.username, profilePic: post.profilePic, material: .thickMaterial)
      Text(post.username)
      Text("•")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(post.createdAt.toDate().formatted())
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .foregroundStyle(.primary)
    .onTapGesture { store.openProfile(id: post.userId, username: post.username, profilePic: post.profilePic) }
  }
  
  private func handleLike() {
    if post.liked == 0 {
      post.liked = 1
      post.likesCount += 1
      Task {
        let res = try await NetworkManager.shared.like(postId: post.id)
        if res.liked != 1 {
          post.liked = res.liked
          post.likesCount -= 1
        }
      }
    } else {
      post.liked = 0
      post.likesCount -= 1
      Task {
        let res = try await NetworkManager.shared.unlike(postId: post.id)
        if res.liked != 0 {
          post.liked = res.liked
          post.liked += 1
        }
      }
    }
  }
  
  private func handleFavorite() {
    if post.favorited == 0 {
      post.favorited = 1
      post.favoritesCount += 1
      Task {
        let res = try await NetworkManager.shared.favorite(postId: post.id)
        if res.favorited != 1 {
          post.favorited = res.favorited
          post.favoritesCount -= 1
        }
      }
    } else {
      post.favorited = 0
      post.favoritesCount -= 1
      Task {
        let res = try await NetworkManager.shared.unfavorite(postId: post.id)
        if res.favorited != 0 {
          post.favorited = res.favorited
          post.favoritesCount += 1
        }
      }
    }
  }
}
