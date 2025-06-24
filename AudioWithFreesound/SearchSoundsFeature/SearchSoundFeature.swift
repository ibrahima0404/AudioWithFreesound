//
//  SearchSoundFeature.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 24/06/2025.
//
import Foundation
import ComposableArchitecture

struct SearchSoundState: Equatable {
  var retrievedSounds: [Sound] = []
}

enum SearchSoundAction: Equatable {
  case search(String)
  case retrievedSounds([Sound])
}

struct SearchSoundsEnvironment {
  var searchSoundsRequest: (JSONDecoder, String) async -> Result<SoundAPIResponse, APIError>
}

struct SearchSoundReducer: Reducer {
  typealias State = SearchSoundState
  typealias Action = SearchSoundAction
  let environment: SearchSoundsEnvironment

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .search(let query):
      return .run { [decoder = JSONDecoder()] send in
        let result = await self.environment.searchSoundsRequest(decoder, query)
        switch result {
        case .success(let soundAPIResponse):
          await send(.retrievedSounds(soundAPIResponse.results))
        case .failure(_):
          break
        }
      }
    case .retrievedSounds(let retrievedSounds):
      state.retrievedSounds = retrievedSounds
      return .none
    }
  }
}
