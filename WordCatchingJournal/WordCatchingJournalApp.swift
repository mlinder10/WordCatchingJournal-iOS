//
//  WordCatchingJournalApp.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 8/16/24.
//

import SwiftUI

@main
struct WordCatchingJournalApp: App {
  @ObservedObject private var store = Store()
  
  var body: some Scene {
    WindowGroup {
      if !store.loaded {
        // TODO: replace with loading screen
        Text("Loading")
      } else {
        if store.user != nil {
          ProtectedRoutes()
        } else {
          AuthRoutes()
        }
      }
    }
    .environmentObject(store)
  }
}

enum AuthPage {
  case login, register
}

struct AuthRoutes: View {
  @State private var page: AuthPage = .login
  
  var body: some View {
    Group {
      if page == .login {
        LoginPage { page = .register }
        Text("")
      } else if page == .register {
        RegisterPage { page = .login }
      }
    }
  }
}

struct ProtectedRoutes: View {
  @EnvironmentObject private var store: Store
  
  var body: some View {
    TabView {
      FeedPage()
        .tabItem { Label("Feed", systemImage: "calendar") }
      PostPage()
        .tabItem { Label("Post", systemImage: "plus")}
      SearchPage()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
    }
    .sheet(isPresented: $store.profileShown) {
      if let user = store.user {
        ProfilePage(userId: user.id, username: user.username, profilePic: user.profilePic)
      }
    }
  }
}
