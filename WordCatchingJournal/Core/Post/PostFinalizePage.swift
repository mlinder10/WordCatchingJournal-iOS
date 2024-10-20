//
//  DefinitionSelectionPage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 10/19/24.
//

import SwiftUI

struct PostFinalizePage: View {
  @EnvironmentObject private var store: Store
  @State private var post = Response<Post?>(nil)
  @State var word: String
  @State var partOfSpeech: PartOfSpeech
  @State var definition: String
  
  var body: some View {
    VStack {
      HStack {
        TextField("Word", text: $word)
        Spacer()
        Picker("Part of Speech", selection: $partOfSpeech) {
          ForEach(PartOfSpeech.allCases) {
            Text($0.rawValue)
              .tag($0)
          }
        }
      }
      TextField("Definition", text: $definition, axis: .vertical)
        .lineLimit(5, reservesSpace: true)
      Button { handlePost() } label: {
        Label("Post", systemImage: "arrow.up")
      }
      .disabled(post.loading)
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .navigationTitle("Post")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  func handlePost() {
    Task {
      await post.call("Failed to post \(word)") {
        try await NetworkManager.shared.createPost(
          word: word,
          definition: definition,
          partOfSpeech: partOfSpeech.rawValue,
          userId: store.user?.id ?? ""
        )
      }
    }
  }
}

#Preview {
  NavigationStack {
    PostFinalizePage(word: "Text", partOfSpeech: .noun, definition: "Some definition")
  }
}
