//
//  Store.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import Foundation

enum Tabs {
  case home
  case post
  case search
  case profile
}

enum Route: Hashable {
  case profile(ProfileData)
}

struct ProfileData: Hashable {
  let id: String
  let username: String
  let profilePic: String?
}

final class Store: ObservableObject {
  @Published var user: User? = nil { didSet { saveToken() } }
  @Published var loaded = false
  
  @Published var tab: Tabs = .home
  @Published var homeRoute = [Route]()
  @Published var postRoute = [Route]()
  @Published var searchRoute = [Route]()
  @Published var profileRoute = [Route]()
  private var currentRoute: [Route] {
    get {
      return switch tab {
      case .home:
        homeRoute
      case .post:
        postRoute
      case .search:
        searchRoute
      case .profile:
        profileRoute
      }
    }
    set {
      switch tab {
      case .home:
        homeRoute = newValue
      case .post:
        postRoute = newValue
      case .search:
        searchRoute = newValue
      case .profile:
        profileRoute = newValue
      }
    }
  }
  
  init() {
    Task {
      let user = try? await NetworkManager.shared.loginWithToken()
      await MainActor.run {
        self.user = user
        self.loaded = true
      }
    }
  }
  
  private func saveToken() {
    guard let user = self.user, let token = user.token else { return }
    let _ = Keychain.shared.save(key: .token, data: token)
  }
  
  private func deleteToken() {
    let _ = Keychain.shared.save(key: .token, data: nil as String?)
  }
  
  func logout() {
    self.user = nil;
    deleteToken()
  }
  
  func openProfile() {
    guard let user else { return }
    openProfile(id: user.id, username: user.username, profilePic: user.profilePic)
  }
  
  func openProfile(id: String, username: String, profilePic: String?) {
    if id != user?.id {
      currentRoute.append(.profile(ProfileData(id: id, username: username, profilePic: profilePic)))
      return
    }
    
    if tab == .profile {
      currentRoute.append(.profile(ProfileData(id: id, username: username, profilePic: profilePic)))
    } else {
      tab = .profile
    }
  }
  
  func canNavigateBack() -> Bool {
    return !currentRoute.isEmpty
  }
  
  func navigateBack() {
    if canNavigateBack() {
      currentRoute.removeLast()
    }
  }
}
