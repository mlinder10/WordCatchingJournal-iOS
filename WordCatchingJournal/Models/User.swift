//
//  User.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/25/24.
//

import Foundation

struct User: Codable, Identifiable {
  let id: String
  let token: String?
  let username: String
  let profilePic: String?
}
