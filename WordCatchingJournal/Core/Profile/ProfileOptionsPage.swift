//
//  ProfileOptionsPage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 10/19/24.
//

import SwiftUI

struct ProfileOptionsPage: View {
  @EnvironmentObject private var store: Store
  
  var body: some View {
    Form {
      Button { store.logout() } label: {
        Text("Logout")
      }
    }
  }
}

#Preview {
  ProfileOptionsPage()
}
