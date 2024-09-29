//
//  Base64Image.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct Base64Image<T: View>: View {
  let data: String?
  @ViewBuilder let fallback: T
  
  var body: some View {
    if let data, let bytes = Data(base64Encoded: data), let uiImage = UIImage(data: bytes) {
      Image(uiImage: uiImage)
    } else {
      fallback
    }
  }
}
