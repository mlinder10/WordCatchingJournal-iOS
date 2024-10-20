//
//  Store.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import Foundation
import SwiftUI

enum Tabs {
  case home
  case post
  case search
  case profile
}

enum Route: Hashable {
  // shared
  case profile(ProfileData)
  
  // post
  case postFinalize(Definition)
  
  // profile
  case editProfile(ProfileData)
  case profileOptions
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
  
  // shared
  
  func canNavigateBack() -> Bool {
    return !currentRoute.isEmpty
  }
  
  func navigateBack() {
    if canNavigateBack() {
      currentRoute.removeLast()
    }
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
  
  // post
  
  func openPostFinalize(_ definition: Definition) {
    guard tab == .post else { return }
    postRoute.append(.postFinalize(definition))
  }
  
  // profile
  
  func openProfile() {
    guard let user else { return }
    openProfile(id: user.id, username: user.username, profilePic: user.profilePic)
  }
  
  func openEditProfile() {
    guard let user, tab == .profile else { return }
    profileRoute.append(.editProfile(ProfileData(id: user.id, username: user.username, profilePic: user.profilePic)))
  }
  
  func openProfileOptions() {
    guard tab == .profile else { return }
    profileRoute.append(.profileOptions)
  }
}

extension View {
  func rootNavigator() -> some View {
    self.navigationDestination(for: Route.self) { route in
        switch route {
        case .profile(let profile):
          ProfilePage(userId: profile.id, username: profile.username, profilePic: profile.profilePic)
        case .editProfile(let profile):
          EditProfilePage(username: profile.username, profilePic: profile.profilePic, userId: profile.id)
        case .profileOptions:
          ProfileOptionsPage()
        case .postFinalize(let def):
          PostFinalizePage(
            word: def.word,
            partOfSpeech: PartOfSpeech(rawValue: def.partOfSpeech) ?? .noun,
            definition: def.definition
          )
        }
      }
  }
}
