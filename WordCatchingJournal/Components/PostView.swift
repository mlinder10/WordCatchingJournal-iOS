//
//  PostView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct PostView: View {
  @EnvironmentObject private var store: Store
  let post: Post
  
  var body: some View {
    VStack(alignment: .leading) {
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
  }
}
