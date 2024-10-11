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
  let userId: String
  let username: String
  let profilePic: String?
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          HStack {
            VStack {
              ProfilePic(username: username, profilePic: profilePic)
              Text(username)
            }
            Spacer()
            HStack {
              VStack {
                Text("Posts")
                Text("\(profileData.data.user.posts)")
              }
              VStack {
                Text("Followers")
                Text("\(profileData.data.user.followers)")
              }
              VStack {
                Text("Following")
                Text("\(profileData.data.user.following)")
              }
            }
          }
          HStack {
            Button { store.logout() } label: {
              Text("Logout")
            }
          }
          LazyVStack {
            ForEach($profileData.data.posts) { post in
              PostView(post: post)
              Divider()
                .padding()
            }
          }
        }
      }
    }
    .task { await fetchProfileData() }
  }
  
  func fetchProfileData() async {
    await profileData.fetch("Failed to fetch profile data") {
      try await NetworkManager.shared.fetchProfileData(userId: userId, localUserId: store.user?.id ?? "")
    }
  }
}

