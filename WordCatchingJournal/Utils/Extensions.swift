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
  func compress(quality: CGFloat, width: CGFloat, height: CGFloat) async -> Data? {
    let data = try? await self.loadTransferable(type: Data.self)
    guard let data, let image = UIImage(data: data) else { return nil }
    let resized = image.resize(width: width, height: height)
    return resized.jpegData(compressionQuality: quality)
  }
  
  func toBytes() async -> Data? {
    try? await self.loadTransferable(type: Data.self)
  }
  
  func toBase64() async -> String? {
    try? await self.loadTransferable(type: Data.self)?.base64EncodedString()
  }
}

extension UIImage {
  func resize(width: CGFloat, height: CGFloat) -> UIImage {
    let size = self.size
    
    let widthRatio  = width  / size.width
    let heightRatio = height / size.height
    
    // Determine the scale factor to maintain aspect ratio
    let scaleFactor = min(widthRatio, heightRatio)
    
    // Calculate the new image size
    let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    
    // Resize the image
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    self.draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage ?? self
  }
}
