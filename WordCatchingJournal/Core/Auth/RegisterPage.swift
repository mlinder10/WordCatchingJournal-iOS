//
//  RegisterView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct RegisterPage: View {
  @EnvironmentObject private var store: Store
  @State private var register = Response<User?>(nil)
  @State private var username = ""
  @State private var email = ""
  @State private var password = ""
  let login: () -> Void
  
  var body: some View {
    VStack {
      Spacer()
      VStack {
        TextField("Email", text: $email)
          .keyboardType(.emailAddress)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
        TextField("Username", text: $username)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
        SecureField("Password", text: $password)
      }
      .padding()
      VStack(spacing: 16) {
        Button { handleRegister() } label: {
          Text("Register")
            .frame(maxWidth: .infinity)
        }
        .disabled(register.loading)
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
        Button { login() } label: {
          Text("Login")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      }
    }
    .padding()
  }
  
  func handleRegister() {
    Task {
      await register.call("Failed to register") {
        let user = try await NetworkManager.shared.register(email: email, username: username, password: password)
        store.user = user
        return user
      }
    }
  }
}
