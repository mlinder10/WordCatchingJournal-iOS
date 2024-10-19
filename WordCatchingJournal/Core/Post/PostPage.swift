//
//  CreatePage.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/28/24.
//

import SwiftUI

enum PartOfSpeech: String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  
  case noun = "Noun"
  case verb = "Verb"
  case adjective = "Adjective"
  case adverb = "Adverb"
  case pronoun = "Pronoun"
  case preposition = "Preposition"
  case conjunction = "Conjunction"
  case interjection = "Interjection"
}

struct PostPage: View {
  @EnvironmentObject private var store: Store
  @State private var search = ""
  @State private var word = ""
  @State private var definition = ""
  @State private var partOfSpeech: PartOfSpeech = .noun
  @State private var definitions = Response([DefinitionResponse.Word]())
  @State private var post = Response<Post?>(nil)
  @State private var fetchTimer: Timer?
  
  var body: some View {
    VStack {
      DefinitionsView(definitions: definitions) {
        word = $0
        definition = $1
        partOfSpeech = PartOfSpeech(rawValue: $2) ?? .noun
      }
      .overlay(alignment: .bottomTrailing) {
        if word != "" && definition != "" {
          Button { handlePost() } label: {
            Image(systemName: "plus")
              .fontWeight(.semibold)
              .padding(4)
          }
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.circle)
          .padding(.bottom)
          .padding(.trailing)
        }
      }
      VStack {
        Divider()
        HStack {
          TextField("Word", text: $word)
          Spacer()
          Picker("Part Of Speech", selection: $partOfSpeech) {
            ForEach(PartOfSpeech.allCases) { pos in
              Text(pos.rawValue)
                .tag(pos)
            }
          }
        }
        TextField("Custom Definition", text: $definition, axis: .vertical)
          .lineLimit(5, reservesSpace: false)
      }
      .padding(.bottom)
      .padding(.horizontal)
    }
    .searchable(text: $search)
    .navigationTitle("Post")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { ProfileLinkView() }
    .onChange(of: search) { fetchDefinitions(word: $1) }
  }
  
  func fetchDefinitions(word: String) {
    fetchTimer?.invalidate()
    if search.count == 0 { return }
    fetchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
      Task {
        await definitions.call("Error finding definitions for \(word)") {
          try await NetworkManager.shared.fetchDefinitions(word: word.lowercased())
        }
      }
    }
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
      word = ""
      definition = ""
      partOfSpeech = .noun
      definitions.data = []
    }
  }
}

fileprivate struct DefinitionsView: View {
  let definitions: Response<[DefinitionResponse.Word]>
  let onTap: (String, String, String) -> Void
  
  var body: some View {
    ScrollView {
      LoadableData(data: definitions) {
        LazyVStack {
          ForEach(definitions.data, id: \.self) { w in
            ForEach(w.meanings, id: \.self) { m in
              ForEach(m.definitions, id: \.self) { d in
                GroupBox {
                  VStack(alignment: .leading) {
                    Text(w.word.capitalized)
                      .fontWeight(.semibold)
                    Text(d.definition)
                    Text(m.partOfSpeech.capitalized)
                      .italic()
                      .foregroundStyle(.secondary)
                      .font(.caption)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onTapGesture { onTap(w.word.capitalized, d.definition, m.partOfSpeech.capitalized) }
              }
            }
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  PostPage()
}
