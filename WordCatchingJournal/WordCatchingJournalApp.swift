//
//  WordCatchingJournalApp.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 8/16/24.
//

import SwiftUI

@main
struct WordCatchingJournalApp: App {
  @StateObject private var store = Store()
  
  var body: some Scene {
    WindowGroup {
      if !store.loaded {
        // TODO: replace with loading screen
        ProgressView("Loading...")
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
      } else if page == .register {
        RegisterPage { page = .login }
      }
    }
  }
}

struct ProtectedRoutes: View {
  @EnvironmentObject private var store: Store
  
  var body: some View {
    TabView(selection: $store.tab) {
      NavigationStack(path: $store.homeRoute) {
        FeedPage()
          .rootNavigator()
      }
      .tabItem { Label("Feed", systemImage: "calendar") }
      .tag(Tabs.home)
      NavigationStack(path: $store.postRoute) {
        PostPage()
          .rootNavigator()
      }
      .tabItem { Label("Post", systemImage: "plus")}
      .tag(Tabs.post)
      NavigationStack(path: $store.searchRoute) {
        SearchPage()
          .rootNavigator()
      }
      .tabItem { Label("Search", systemImage: "magnifyingglass") }
      .tag(Tabs.search)
      NavigationStack(path: $store.profileRoute) {
        ProfilePage(userId: store.user?.id ?? "", username: store.user?.username ?? "", profilePic: store.user?.profilePic ?? "")
          .rootNavigator()
      }
      .tabItem { Label("Profile", systemImage: "person") }
      .tag(Tabs.profile)
    }
  }
}
