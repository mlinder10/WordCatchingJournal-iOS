//
//  DefinitionResponse.swift
//  WordCatchingJournal
//
//  Created by Matt Linder on 9/25/24.
//

import Foundation

enum DefinitionResponse {
  struct Word: Codable, Hashable {
    let word: String
    let phonetic: String
    let meanings: [Meaning]
  }
  
  struct Meaning: Codable , Hashable{
    let partOfSpeech: String
    let definitions: [Definition]
  }
  
  struct Definition: Codable, Hashable {
    let definition: String
    let synonyms: [String]?
    let antonyms: [String]?
  }
  
  struct Response: Codable, Hashable {
    let word: String?
    let phonetic: String?
    let origin: String?
    let partOfSpeech: String?
    let definition: String?
    let example: String?
    let synonyms: [String]?
    let antonyms: [String]?
    
//    static func from(_ words: [Word]) -> [Response] {
//      return words.flatMap { word in
//        word.meanings.flatMap { meaning in
//          meaning.definitions.compactMap { definition in
//            Response(
//              word: word.word,
//              phonetic: word.phonetic,
//              origin: word.origin,
//              partOfSpeech: meaning.partOfSpeech,
//              definition: definition.definition,
//              example: definition.example,
//              synonyms: definition.synonyms,
//              antonyms: definition.antonyms
//            )
//          }
//        }
//      }
//    }
  }
}
