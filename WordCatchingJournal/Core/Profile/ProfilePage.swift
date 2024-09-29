//
//  ProfilePage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct ProfilePage: View {
  let userId: String
  let username: String
  let profilePic: String?
  
  var body: some View {
    VStack {
      HStack {
        VStack {
          ProfilePic(username: username, profilePic: profilePic)
          Text(username)
        }
        Spacer()
        HStack {
          
        }
      }
    }
  }
}

