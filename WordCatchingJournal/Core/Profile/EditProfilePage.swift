//
//  EditProfilePage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 10/19/24.
//

import SwiftUI
import PhotosUI

struct EditProfilePage: View {
  @Environment(\.dismiss) private var dismiss
  @State private var saveChanges = Response<String?>(nil)
  @State private var username: String
  @State private var profilePic: String?
  @State private var photo: PhotosPickerItem?
  let userId: String
  
  init(userId: String, username: String, profilePic: String?) {
    self.userId = userId
    self.username = username
    self.profilePic = profilePic
  }
  
  var body: some View {
    Form {
      PhotosPicker(selection: $photo, matching: .images) {
        VStack(spacing: 12) {
          ProfilePic(username: username, profilePic: profilePic, size: 100, material: .ultraThick)
          Text("Edit Picture")
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .listRowInsets(EdgeInsets())
      .listRowBackground(Color.clear)
      Section {
        TextField("Username", text: $username)
      }
      Section {
        Button {
          handleSave()
        } label: {
          Text("Save")
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .disabled(saveChanges.loading)
        Button(role: .destructive) {
          dismiss()
        } label: {
          Text("Cancel")
            .frame(maxWidth: .infinity, alignment: .center)
        }
      }
    }
    .navigationTitle("Edit Profile")
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: photo) { handleUploadProfilePic($1) }
  }
  
  func handleSave() {
    Task {
      await saveChanges.call("Error saving changes") {
        try await NetworkManager.shared.editProfile(username: username, profilePic: profilePic)
      }
    }
  }
  
  func handleUploadProfilePic(_ photo: PhotosPickerItem?) {
    Task {
      let b64 = await photo?.toBase64()
      await MainActor.run {
        self.profilePic = b64
      }
    }
  }
}

#Preview {
  NavigationStack {
    EditProfilePage(userId: "", username: "mattl", profilePic: nil)
  }
}
