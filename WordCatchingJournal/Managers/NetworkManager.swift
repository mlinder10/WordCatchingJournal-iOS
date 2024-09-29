//
//  NetworkManager.swift
//  CapstoneProject
//
//  Created by Matt Linder on 9/1/24.
//

import Foundation

struct Response<T> {
  var data: T
  var loading: Bool = false
  var error: String? = nil
  
  init(_ data: T) {
    self.data = data
  }
  
  mutating func fetch(_ errorMessage: String = "", function: @escaping () async throws -> T) async {
    self.loading = true
    self.error = nil
    do {
      self.data = try await function()
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
  
//  private let SERVER_URL = "http://127.0.0.1:3000"
  private let SERVER_URL = "https://word-catching-journal.vercel.app"
  private let HEADERS = [
    "Content-Type": "application/json"
  ]
  
  private let client: HttpClient
  
  private init() {
    self.client = HttpClient(baseUrl: SERVER_URL, headers: HEADERS)
  }
  
  func login(email: String, password: String) async throws -> User {
    return try await client.request(
      method: .post,
      route: "/api/auth/login",
      body: [
        "email": email,
        "password": password
      ]
    )
  }
  
  func register(email: String, username: String, password: String) async throws -> User {
    return try await client.request(
      method: .post,
      route: "/api/auth/register",
      body: [
        "email": email,
        "username": username,
        "password": password
      ]
    )
  }
  
  func loginWithToken() async throws -> User? {
    guard let token: String = Keychain.shared.load(key: .token) else { return nil }
    return try await client.request(
      route: "/api/auth/token/\(token)"
    )
  }
  
  func fetchDefinitions(word: String) async throws -> [DefinitionResponse.Word] {
    let client = HttpClient(baseUrl: DICT_URL)
    return try await client.request(route: word)
  }
  
  func fetchPosts() async throws -> [Post] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(route: "/api/posts")
  }
  
  func fetchFollowingPosts(userId: String) async throws -> [Post] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(route: "/api/posts/following/\(userId)")
  }
  
  func fetchUserPosts(userId: String) async throws -> [Post] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(route: "/api/posts/\(userId)")
  }
  
  func createPost(word: String, definition: String, partOfSpeech: String, userId: String) async throws -> Post {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .post,
      route: "/api/posts",
      body: [
        "word": word,
        "definition": definition,
        "partOfSpeech": partOfSpeech,
        "userId": userId
      ]
    )
  }
  
  func updatePost(postId: String, word: String, definition: String, partOfSpeech: String) async throws -> Post {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .patch,
      route: "/api/posts/\(postId)",
      body: [
        "word": word,
        "definition": definition,
        "partOfSpeech": partOfSpeech
      ]
    )
  }
  
  func deletePost(postId: String) async throws -> String {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .delete,
      route: "/api/posts/\(postId)"
    )
  }
  
  enum SearchResult: Codable, Identifiable {
    var id: String {
      return switch self {
      case .post(let post):
        post.id
      case .user(let user):
        user.id
      }
    }
    case post(Post)
    case user(User)
  }
  
  func fetchSearchResults(search: String, filter: [String] = []) async throws -> [SearchResult] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .post,
      route: "/api/search",
      body: [
        "search": search,
        "filter": filter
      ]
    )
  }
  
  struct ProfileData: Codable {
    let user: User
    let posts: [Post]
    let isFollowing: Bool
    
    struct User: Codable {
      let id: String
      let username: String
      let profilePic: String
      let posts: Int
      let following: Int
      let followers: Int
    }
  }
  
  func fetchProfileData(userId: String, localUserId: String) async throws -> ProfileData {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .get,
      route: "/api/user/\(userId)/\(localUserId)"
    )
  }
  
  func fetchFollowing(userId: String) async throws -> [User] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      route: "/api/follow/following/\(userId)"
    )
  }
  
  func fetchFollowers(userId: String) async throws -> [User] {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      route: "/api/follow/followers/\(userId)"
    )
  }
  
  func follow(userId: String, localUserId: String) async throws -> String {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .post,
      route: "/api/follow",
      body: [
        "userId": localUserId,
        "followedUserId": userId
      ]
    )
  }
  
  func unfollow(userId: String, localUserId: String) async throws -> String {
    let client = HttpClient(baseUrl: SERVER_URL)
    return try await client.request(
      method: .post,
      route: "/api/follow/delete",
      body: [
        "userId": localUserId,
        "followedUserId": userId
      ]
    )
  }
}
