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
  @State private var word = ""
  @State private var definition = ""
  @State private var partOfSpeech: PartOfSpeech = .noun
  @State private var definitions = Response([DefinitionResponse.Word]())
  
  var body: some View {
    NavigationStack {
      VStack {
        DefinitionsView(definitions: definitions) { self.definition = $0 }
        Divider()
        InputsView(
          word: $word,
          definition: $definition,
          partOfSpeech: $partOfSpeech,
          fetchDefinitions: fetchDefinitions
        )
      }
      .navigationTitle("Post")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ProfileLinkView()
      }
    }
  }
  
  func fetchDefinitions() {
    Task {
      await definitions.fetch("Failed to fetch definitions") {
        try await NetworkManager.shared.fetchDefinitions(word: word.lowercased())
      }
    }
  }
  
  func handlePost() {
    Task {}
  }
}

fileprivate struct DefinitionsView: View {
  let definitions: Response<[DefinitionResponse.Word]>
  let onTap: (String) -> Void
  
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
                .onTapGesture { onTap(d.definition) }
              }
            }
          }
        }
      }
      .padding()
    }
  }
}

fileprivate struct InputsView: View {
  @Binding var word: String
  @Binding var definition: String
  @Binding var partOfSpeech: PartOfSpeech
  var fetchDefinitions: () -> Void
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        TextField("Word", text: $word)
        Button { fetchDefinitions() } label: {
          Text("Search")
        }
        .buttonStyle(.borderedProminent)
      }
      TextField("Definition", text: $definition)
        .lineLimit(4, reservesSpace: true)
      Picker("Part Of Speech", selection: $partOfSpeech) {
        ForEach(PartOfSpeech.allCases) { pos in
          Text(pos.rawValue)
            .tag(pos)
        }
      }
      Button {} label: {
        Text("Post")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
  }
}

#Preview {
  PostPage()
}
