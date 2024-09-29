//
//  HttpClient.swift
//  CapstoneProject
//
//  Created by Matt Linder on 9/1/24.
//

import Foundation

enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

final class HttpClient {
  private var baseUrl: String
  private var headers: [String: String]
  
  init(baseUrl: String = "", headers: [String: String] = [:]) {
    self.baseUrl = baseUrl
    self.headers = headers
  }
  
  func request<T: Decodable>(
    method: RequestMethod = .get,
    route: String = "",
    headers: [String: String] = [:],
    body: [String: Any] = [:]
  ) async throws -> T {
    guard let url = URL(string: baseUrl + route) else { throw URLError(.badURL) }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = self.headers.merging(headers) { $1 }
    
    if method == .post || method == .put || method == .patch {
      let jsonBody = try JSONSerialization.data(withJSONObject: body)
      request.httpBody = jsonBody
    }
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let resp = try JSONDecoder().decode(T.self, from: data)
    return resp
  }
  
  func config(baseUrl: String = "", headers: [String: String] = [:]) {
    self.baseUrl = baseUrl
    self.headers = headers
  }
}
