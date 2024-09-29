//
//  Post.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/25/24.
//

import Foundation

struct Post: Codable, Identifiable {
  let id: String
  let word: String
  let definition: String
  let partOfSpeech: String
  let createdAt: Int
  let updatedAt: Int
  let userId: String
  let username: String
  let profilePic: String?
}
