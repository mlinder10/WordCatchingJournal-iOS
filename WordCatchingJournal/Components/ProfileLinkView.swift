//
//  ProfileLinkView.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/28/24.
//

import SwiftUI

struct ProfileLinkView: View {
  @EnvironmentObject private var store: Store
  
  var body: some View {
    ProfilePic(username: store.user?.username ?? "", profilePic: store.user?.profilePic)
      .onTapGesture { store.openProfile() }
  }
}

#Preview {
    ProfileLinkView()
}
