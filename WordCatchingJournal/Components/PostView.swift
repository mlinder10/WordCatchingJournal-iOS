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
      if post.userId == store.user?.id {
        profileLinkHeader
      } else {
        userLinkHeader
      }
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
        HStack {
          Image(systemName: post.favorited == 1 ? "star.fill" : "star")
            .foregroundStyle(post.favorited == 1 ? .yellow : .secondary)
          Text("\(post.favoritesCount) \(post.favoritesCount == 1 ? "Favorite" : "Favorites")")
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }
  
  private var profileLinkHeader: some View {
    HStack {
      ProfilePic(username: post.username, profilePic: post.profilePic, material: .thickMaterial)
      Text(post.username)
      Spacer()
    }
    .onTapGesture {
      store.profileShown = true
    }
  }
  
  private var userLinkHeader: some View {
    NavigationLink {
      ProfilePage(userId: post.userId, username: post.username, profilePic: post.profilePic)
    } label: {
      HStack {
        ProfilePic(username: post.username, profilePic: post.profilePic, material: .thickMaterial)
        Text(post.username)
        Spacer()
      }
    }
    .foregroundStyle(.primary)
  }
  
  private func handleLike() {}
  
  private func handleFavorite() {}
}
