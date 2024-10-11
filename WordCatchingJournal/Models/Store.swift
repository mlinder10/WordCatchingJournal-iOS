//
//  Store.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import Foundation

final class Store: ObservableObject {
  @Published var user: User? = nil { didSet { saveToken() } }
  @Published var loaded = false
  @Published var profileShown = false
  
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
}
