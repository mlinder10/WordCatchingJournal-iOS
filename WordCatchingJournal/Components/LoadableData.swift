//
//  LoadableData.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/27/24.
//

import SwiftUI

struct LoadableData<T, U: View>: View {
  var data: Response<T>
  @ViewBuilder var content: U
  
  var body: some View {
    Group {
      if data.loading {
        ProgressView()
      } else {
        if let error = data.error {
          Text(error)
        } else {
          content
        }
      }
    }
  }
}
