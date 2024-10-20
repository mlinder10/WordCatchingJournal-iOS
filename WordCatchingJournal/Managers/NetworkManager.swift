//
//  NetworkManager.swift
//  CapstoneProject
//
//  Created by Matt Linder on 9/1/24.
//

import Foundation
import SwiftUI

@Observable
final class Response<T> {
  var data: T
  var loading: Bool = false
  var error: String? = nil
  
  init(_ data: T) {
    self.data = data
  }
  
  func call(_ errorMessage: String = "", function: @escaping () async throws -> T) async {
    self.loading = true
    self.error = nil
    do {
      let data = try await function()
      self.data = data
    } catch {
      print(error.localizedDescription)
      self.error = errorMessage
    }
    self.loading = false
  }
}

private let DICT_URL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

final class NetworkManager {
  static let shared = NetworkManager()
  
//  private let SERVER_URL = "http://127.0.0.1:3000/api"
  private let SERVER_URL = "https://word-catching-journal.vercel.app/api"
  private let HEADERS = [
    "Content-Type": "application/json",
    "Authorization": Keychain.shared.load(key: .token) ?? ""
  ]
  
  private let client: HttpClient
  
  private init() {
    self.client = HttpClient()
    self.client.config(baseUrl: SERVER_URL, headers: HEADERS)
  }
  
  func login(email: String, password: String) async throws -> User {
    let user: User = try await client.request(
      method: .post,
      route: "/auth/login",
      body: [
        "email": email,
        "password": password
      ]
    )
    self.client.config(headers: ["Authorization": user.token ?? ""])
    return user
  }
  
  func register(email: String, username: String, password: String) async throws -> User {
    let user: User = try await client.request(
      method: .post,
      route: "/auth/register",
      body: [
        "email": email,
        "username": username,
        "password": password
      ]
    )
    self.client.config(headers: ["Authorization": user.token ?? ""])
    return user
  }
  
  func loginWithToken() async throws -> User? {
    guard let token: String = Keychain.shared.load(key: .token) else { return nil }
    return try await self.client.request(
      route: "/auth/token/\(token)"
    )
  }
  
  func fetchDefinitions(word: String) async throws -> [Definition] {
    let client = HttpClient(baseUrl: DICT_URL)
    let response: [DefinitionResponse.Word] = try await client.request(route: word)
    return response.toModel()
  }
  
  func fetchPosts() async throws -> [Post] {
    return try await self.client.request(route: "/posts")
  }
  
  func fetchFollowingPosts(userId: String) async throws -> [Post] {
    return try await self.client.request(route: "/posts/following/\(userId)")
  }
  
  func fetchUserPosts(userId: String) async throws -> [Post] {
    return try await self.client.request(route: "/posts/\(userId)")
  }
  
  func createPost(word: String, definition: String, partOfSpeech: String, userId: String) async throws -> Post {
    return try await self.client.request(
      method: .post,
      route: "/posts",
      body: [
        "word": word,
        "definition": definition,
        "partOfSpeech": partOfSpeech,
        "userId": userId
      ]
    )
  }
  
  func updatePost(postId: String, word: String, definition: String, partOfSpeech: String) async throws -> Post {
    return try await self.client.request(
      method: .patch,
      route: "/posts/\(postId)",
      body: [
        "word": word,
        "definition": definition,
        "partOfSpeech": partOfSpeech
      ]
    )
  }
  
  func deletePost(postId: String) async throws -> String {
    return try await self.client.request(
      method: .delete,
      route: "/posts/\(postId)"
    )
  }
  
  enum SearchResult: Decodable {
    case post(Post)
    case user(User)
    
    private enum CodingKeys: String, CodingKey {
      case type
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .type)
      let singleValueContainer = try decoder.singleValueContainer()
      
      switch type {
      case "post":
        let post = try singleValueContainer.decode(Post.self)
        self = .post(post)
      case "user":
        let user = try singleValueContainer.decode(User.self)
        self = .user(user)
      default:
        throw DecodingError.dataCorruptedError(forKey: .type,
                                               in: container,
                                               debugDescription: "Unknown type: \(type)")
      }
    }
  }
  
  func fetchSearchResults(search: String, filter: [String] = []) async throws -> ([User], [Post]) {
    let res: [SearchResult] = try await self.client.request(
      method: .post,
      route: "/search",
      body: [
        "search": search,
        "filter": filter
      ]
    )
  
    var users = [User]()
    var posts = [Post]()
    
    for obj in res {
      switch obj {
      case .post(let post):
        posts.append(post)
      case .user(let user):
        users.append(user)
      }
    }
    
    return (users, posts)
  }
  
  struct ProfileData: Codable {
    var user: User
    var posts: [Post]
    var isFollowing: Bool
    
    struct User: Codable {
      let id: String
      let username: String
      let profilePic: String?
      let posts: Int
      var following: Int
      var followers: Int
    }
  }
  
  func fetchProfileData(userId: String, localUserId: String) async throws -> ProfileData {
    return try await self.client.request(
      method: .get,
      route: "/users/\(userId)/\(localUserId)"
    )
  }
  
  func fetchFollowing(userId: String) async throws -> [User] {
    return try await self.client.request(
      route: "/follow/following/\(userId)"
    )
  }
  
  func fetchFollowers(userId: String) async throws -> [User] {
    return try await self.client.request(
      route: "/follow/followers/\(userId)"
    )
  }
  
  func follow(userId: String, localUserId: String) async throws -> String {
    return try await self.client.request(
      method: .post,
      route: "/follow",
      body: [
        "userId": localUserId,
        "followedUserId": userId
      ]
    )
  }
  
  func unfollow(userId: String, localUserId: String) async throws -> String {
    return try await self.client.request(
      method: .post,
      route: "/follow/delete",
      body: [
        "userId": localUserId,
        "followedUserId": userId
      ]
    )
  }
  
  struct LikeResponse: Codable {
    let liked: Int
  }
  
  func like(postId: String) async throws -> LikeResponse {
    return try await self.client.request(
      method: .post,
      route: "/like",
      body: [
        "postId": postId
      ]
    )
  }
  
  func unlike(postId: String) async throws -> LikeResponse {
    return try await self.client.request(
      method: .post,
      route: "/like/delete",
      body: [
        "postId": postId
      ]
    )
  }
  
  struct FavoriteResponse: Codable {
    let favorited: Int
  }
  
  func favorite(postId: String) async throws -> FavoriteResponse {
    return try await self.client.request(
      method: .post,
      route: "/favorite",
      body: [
        "postId": postId
      ]
    )
  }
  
  func unfavorite(postId: String) async throws -> FavoriteResponse {
    return try await self.client.request(
      method: .post,
      route: "/favorite/delete",
      body: [
        "postId": postId
      ]
    )
  }
  
  func editProfile(userId: String, username: String, profilePic: String?) async throws -> String {
    return try await self.client.request(
      method: .patch,
      route: "/users/\(userId)",
      body: [
        "username": username,
        "profilePic": profilePic as Any
      ]
    )
  }
}
