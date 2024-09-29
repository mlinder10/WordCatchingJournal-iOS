//
//  KeychainManager.swift
//  LiftLogsPro
//
//  Created by Matt Linder on 7/15/24.
//

import Foundation
import Security

enum KeychainKey: String {
  case token = "token"
}

final class Keychain {
  
  static let shared = Keychain()
  
  private init() {}
  
  func save<T: Encodable>(key: KeychainKey, data: T) -> OSStatus {
    guard let jsonData = try? JSONEncoder().encode(data) else {
      return -1
    }
    
    let query = [
      kSecClass as String       : kSecClassGenericPassword as String,
      kSecAttrAccount as String : key.rawValue,
      kSecValueData as String   : jsonData ] as [String : Any]
    
    SecItemDelete(query as CFDictionary)
    
    return SecItemAdd(query as CFDictionary, nil)
  }
  
  func load<T: Decodable>(key: KeychainKey) -> T? {
    let query = [
      kSecClass as String       : kSecClassGenericPassword,
      kSecAttrAccount as String : key.rawValue,
      kSecReturnData as String  : kCFBooleanTrue!,
      kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
    
    var dataTypeRef: AnyObject? = nil
    
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status != noErr {
      return nil
    }
    
    guard let jsonData = dataTypeRef as! Data? else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: jsonData)
  }
  
  class func createUniqueID() -> String {
    let uuid: CFUUID = CFUUIDCreate(nil)
    let cfStr: CFString = CFUUIDCreateString(nil, uuid)
    
    let swiftString: String = cfStr as String
    return swiftString
  }
}
