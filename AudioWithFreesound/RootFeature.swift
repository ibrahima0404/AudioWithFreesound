//
//  RootFeature.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 26/06/2025.
//

import Foundation
import ComposableArchitecture
import AVFoundation

struct AppState: Equatable {
  var searchSound = SearchSoundState()
  var playSound = PlaySoundState()
}

enum AppAction {
  case searchSound(SearchSoundAction)
  case playSound(PlaySoundAction)
}

struct AppReducer: Reducer {
  typealias State = AppState
  typealias Action = AppAction

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .searchSound(.onSelect(sound)):
      return .send(.playSound(.soundToPlay(sound)))
    case let .searchSound(childAction):
      return SearchSoundReducer(environment: SearchSoundsEnvironment(searchSoundsRequest: searchSoundsEffect))
        .reduce(into: &state.searchSound, action: childAction)
        .map { Action.searchSound($0) }
    case let .playSound(childAction):
      return PlaySoundReducer(environment: PlaySoundEnvironment(soundRequest: soundRequestEffects, mainQueue: .main, audioClient: AudioPlayerClientKey.liveValue))
        .reduce(into: &state.playSound, action: childAction)
        .map { Action.playSound($0) }
    }
  }
}
