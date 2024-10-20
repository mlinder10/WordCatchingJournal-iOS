//
//  EditProfilePage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 10/19/24.
//

import SwiftUI
import PhotosUI

// Might want to update each attribute with seperate api calls
// so images don't need to be sent on each one
struct EditProfilePage: View {
  @EnvironmentObject private var store: Store
  @Environment(\.dismiss) private var dismiss
  @State private var saveChanges = Response<String?>(nil)
  @State var username: String
  @State var profilePic: String?
  @State private var photo: PhotosPickerItem?
  let userId: String
  
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
        let res = try await NetworkManager.shared.editProfile(userId: userId, username: username, profilePic: profilePic)
        store.user?.username = username
        store.user?.profilePic = profilePic
        return res
      }
      if saveChanges.error == nil {
        dismiss()
      }
    }
  }
  
  func handleUploadProfilePic(_ photo: PhotosPickerItem?) {
    Task {
      let b64 = await photo?.compress(quality: 0.7, width: 300, height: 300)?.base64EncodedString()
      await MainActor.run {
        self.profilePic = b64
      }
    }
  }
}

#Preview {
  NavigationStack {
    EditProfilePage(username: "mattl", profilePic: nil, userId: "")
  }
}
