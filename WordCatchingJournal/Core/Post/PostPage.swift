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
  @State private var selectedDefinition: Definition? = nil
  @State private var definitions = Response([Definition]())
  @State private var post = Response<Post?>(nil)
  @State private var fetchTimer: Timer?
  
  var body: some View {
    Group {
      if definitions.loading {
        loadingView
      } else if search.isEmpty {
        emptyView
      } else if definitions.error != nil {
        errorView
      }  else {
        defsView
      }
    }
    .searchable(text: $search)
    .navigationTitle("Post")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { ProfileLinkView() }
    .onChange(of: search) { fetchDefinitions(word: $1) }
    .overlay(alignment: .bottomTrailing) {
      if let selectedDefinition {
        Button { store.openPostFinalize(selectedDefinition) } label: {
          Image(systemName: "arrow.right")
            .fontWeight(.semibold)
            .padding(4)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .padding(.bottom)
        .padding(.trailing)
      }
    }
  }
  
  var loadingView: some View {
    ProgressView()
  }
  
  var emptyView: some View {
    VStack {
      Text("Search for a word's definitions or create one yourself")
        .multilineTextAlignment(.center)
      Button {
        store.openPostFinalize(Definition(word: "", definition: "", partOfSpeech: ""))
      } label: {
        HStack {
          Text("Custom")
          Image(systemName: "arrow.right")
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
  
  var errorView: some View {
    VStack {
      Text("No results for \"\(search)\"")
        .fontWeight(.semibold)
      Text("Enter a custom definition")
        .foregroundStyle(.secondary)
      Button {
        store.openPostFinalize(Definition(word: search, definition: "", partOfSpeech: ""))
      } label: {
        HStack {
          Text("Next")
          Image(systemName: "arrow.right")
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
  
  var defsView: some View {
    ScrollView {
      LazyVStack {
        ForEach(definitions.data, id: \.hashValue) { data in
          GroupBox {
            VStack(alignment: .leading) {
              Text(data.word.capitalized)
                .fontWeight(.semibold)
              Text(data.definition)
              Text(data.partOfSpeech.capitalized)
                .italic()
                .foregroundStyle(.secondary)
                .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .border(selectedDefinition == data ? Color.accentColor : Color.clear)
          .onTapGesture {
            selectedDefinition = selectedDefinition == data ? nil : data
          }
        }
      }
      .padding()
    }
    .scrollDismissesKeyboard(.interactively)
  }
  
  func fetchDefinitions(word: String) {
    selectedDefinition = nil
    fetchTimer?.invalidate()
    fetchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
      Task {
        await definitions.call("Error finding definitions for \(word)") {
          try await NetworkManager.shared.fetchDefinitions(word: word.lowercased())
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    PostPage()
  }
}
