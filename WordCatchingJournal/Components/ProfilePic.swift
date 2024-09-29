//
//  ProfilePic.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct ProfilePic: View {
  let username: String
  let profilePic: String?
  var size: CGFloat = 30
  var material: Material = .regularMaterial
  
  var body: some View {
    Base64Image(data: profilePic) {
      Circle()
        .fill(material)
        .frame(width: size, height: size)
        .overlay {
          Text(username.first?.uppercased() ?? "")
            .fontWeight(.semibold)
        }
    }
  }
}
