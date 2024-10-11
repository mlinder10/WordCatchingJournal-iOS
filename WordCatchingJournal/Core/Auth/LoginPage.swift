//
//  LoginView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct LoginPage: View {
  @EnvironmentObject private var store: Store
  @State private var email = ""
  @State private var password = ""
  let register: () -> Void
  
  var body: some View {
    VStack {
      Image("wcj-logo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.vertical, 32)
      TextField("Email", text: $email)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
      SecureField("Password", text: $password)
      Spacer()
      VStack(spacing: 16) {
        Button { handleLogin() } label: {
          Text("Login")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        HStack(spacing: 12) {
          Rectangle()
            .fill(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
          Text("OR")
            .foregroundStyle(.secondary)
            .font(.caption)
          Rectangle()
            .fill(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
        }
        Button { register() } label: {
          Text("Register")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      }
    }
    .padding()
  }
  
  func handleLogin() {
    Task {
      do {
        let user = try await NetworkManager.shared.login(email: email, password: password)
        store.user = user
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
