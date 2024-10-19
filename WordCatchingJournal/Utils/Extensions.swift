//
//  Extensions.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import Foundation
import SwiftUI
import PhotosUI

extension Sequence {
  func asyncMap<T>(
    _ transform: (Element) async throws -> T
  ) async rethrows -> [T] {
    var values = [T]()
    
    for element in self {
      try await values.append(transform(element))
    }
    
    return values
  }
}

extension View {
  func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
    background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
  }
  
  func rootNavigator() -> some View {
    self.navigationDestination(for: Route.self) { route in
        switch route {
        case .profile(let profile):
          ProfilePage(userId: profile.id, username: profile.username, profilePic: profile.profilePic)
        }
      }
  }
}

struct FrameReader: View {
  let coordinateSpace: CoordinateSpace
  let onChange: (_ frame: CGRect) -> ()
  
  public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
    self.coordinateSpace = coordinateSpace
    self.onChange = onChange
  }
  
  public var body: some View {
    GeometryReader{ geo in
      Text("")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
          onChange(geo.frame(in: coordinateSpace))
        }
        .onChange(of: geo.frame(in: coordinateSpace)) { onChange($1) }
    }
  }
}

extension Int {
  func toDate() -> Date {
    Date(timeIntervalSince1970: TimeInterval(self / 1000))
  }
}

extension PhotosPickerItem {
  func toBase64() async -> String? {
    try? await self.loadTransferable(type: Data.self)?.base64EncodedString()
  }
}
