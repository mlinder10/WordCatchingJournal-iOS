//
//  LoginView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct LoginPage: View {
  @EnvironmentObject private var store: Store
  @State private var login = Response<User?>(nil)
  @State private var email = ""
  @State private var password = ""
  let register: () -> Void
  
  var body: some View {
    VStack {
      Spacer()
      VStack {
        TextField("Email", text: $email)
          .keyboardType(.emailAddress)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
        SecureField("Password", text: $password)
      }
      .padding()
      VStack(spacing: 16) {
        Button { handleLogin() } label: {
          Text("Login")
            .frame(maxWidth: .infinity)
        }
        .disabled(login.loading)
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
      await login.call("Login failed") {
        let user = try await NetworkManager.shared.login(email: email, password: password)
        store.user = user
        return user
      }
    }
  }
}
