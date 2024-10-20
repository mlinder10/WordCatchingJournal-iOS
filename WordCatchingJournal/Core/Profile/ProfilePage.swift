//
//  ProfilePage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct ProfilePage: View {
  @EnvironmentObject private var store: Store
  @State private var profileData = Response<NetworkManager.ProfileData>(NetworkManager.ProfileData(user: NetworkManager.ProfileData.User(id: "", username: "", profilePic: nil, posts: 0, following: 0, followers: 0), posts: [], isFollowing: false))
  @State private var follow = Response<String?>(nil)
  let userId: String
  let username: String
  let profilePic: String?
  
  var body: some View {
    ZStack(alignment: .top) {
      ScrollView {
        LazyVStack {
          header
            .padding(.horizontal)
          Divider()
            .padding(.vertical)
          posts
        }
        .padding()
      }
    }
    .task { await fetchProfileData() }
    .navigationTitle(username)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button { store.openProfileOptions() } label: {
          Image(systemName: "line.3.horizontal")
        }
      }
    }
  }
  
  var header: some View {
    HStack {
      ProfilePic(username: username, profilePic: profilePic, size: 80)
      Spacer()
      VStack(spacing: 12) {
        HStack(spacing: 12) {
          VStack {
            Text("Posts")
              .font(.caption)
              .foregroundStyle(.secondary)
            Text("\(profileData.data.user.posts)")
              .fontWeight(.semibold)
          }
          VStack {
            Text("Followers")
              .font(.caption)
              .foregroundStyle(.secondary)
            Text("\(profileData.data.user.followers)")
              .fontWeight(.semibold)
          }
          VStack {
            Text("Following")
              .font(.caption)
              .foregroundStyle(.secondary)
            Text("\(profileData.data.user.following)")
              .fontWeight(.semibold)
          }
        }
        if userId == store.user?.id {
          Button { store.openEditProfile() } label: {
            Text("Edit Profile")
              .font(.caption)
              .frame(width: 150)
          }
          .buttonStyle(.borderedProminent)
        } else {
          Button { handleFollow() } label: {
            Text(profileData.data.isFollowing ? "Unfollow" : "Follow")
              .font(.caption)
              .frame(width: 150)
          }
          .buttonStyle(.borderedProminent)
          .disabled(follow.loading)
        }
      }
    }
  }
  
  var posts: some View {
    ForEach($profileData.data.posts) { post in
      PostView(post: post)
      Divider()
        .padding(.vertical)
    }
  }
  
  func fetchProfileData() async {
    await profileData.call("Failed to load profile") {
      try await NetworkManager.shared.fetchProfileData(userId: userId, localUserId: store.user?.id ?? "")
    }
  }
  
  func handleFollow() {
    guard let user = store.user else { return }
    Task {
      await follow.call {
        if profileData.data.isFollowing {
          let res = try await NetworkManager.shared.unfollow(userId: userId, localUserId: user.id)
          profileData.data.user.followers -= 1
          profileData.data.isFollowing = false
          return res
        } else {
          let res = try await NetworkManager.shared.follow(userId: userId, localUserId: user.id)
          profileData.data.user.followers += 1
          profileData.data.isFollowing = true
          return res
        }
      }
    }
  }
}

