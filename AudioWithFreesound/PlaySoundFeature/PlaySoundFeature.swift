//
//  PlaySoundFeature.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 26/06/2025.
//

import Foundation
import ComposableArchitecture
import AVFoundation

enum PlayerState {
  case playing
  case paused
  case stopped
}

struct PlaySoundState: Equatable {
  var playerState: PlayerState = .stopped
  var selectedSound: SoundMetadata?
  var soundPlaying: SoundMetadata?
  var currentTime: Double = 0
  var duration: Double = 0
}

enum PlaySoundAction: Equatable {
  case play
  case pause
  case endPlaying
  case seek(Double)
  case updateProgress(current: Double, total: Double)
  case soundToPlay(Sound)
  case onRequestSoundFinished(Result<SoundMetadata, APIError>)
}

struct PlaySoundEnvironment {
  var soundRequest: (JSONDecoder, _ id: Int) async -> Result<SoundMetadata, APIError>
  var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  var audioClient: AudioPlayerClient
}

struct PlaySoundReducer: Reducer {
  typealias State = PlaySoundState
  typealias Action = PlaySoundAction
  let environment: PlaySoundEnvironment

  func reduce(into state: inout PlaySoundState, action: PlaySoundAction) -> ComposableArchitecture.Effect<PlaySoundAction> {
    switch action {
    case .play:
      if let url = state.selectedSound?.url {
        environment.audioClient.play(url)
        state.soundPlaying = state.selectedSound
        state.playerState = .playing
      }
      return .merge(
        .run { send in
          for await (progress, total) in environment.audioClient.observeProgress() {
            await send(.updateProgress(current: progress, total: total))
          }
        },
        .run { send in
          for await _ in environment.audioClient.observeDidFinishPlaying() {
            await send(.endPlaying)
          }
        }
      )
    case .pause:
      environment.audioClient.pause()
      state.playerState = .paused
      return .none
    case .soundToPlay(let sound):
      return .run { [decoder = JSONDecoder()] send in
        let result = await environment.soundRequest(decoder, sound.id)
        await send(.onRequestSoundFinished(result))
      }
    case .endPlaying:
      environment.audioClient.stop()
      state.playerState = .stopped
      return .none
    case .onRequestSoundFinished(let result):
      switch result {
      case .success(let soundMetadata):
        state.selectedSound = soundMetadata
        if state.playerState == .playing {
          return .run { send in
            await send(.play)
          }
        }
       case .failure(let error):
        print("Failed to load sound: \(error.localizedDescription)")
      }
      return .none
    case .seek(let time):
      environment.audioClient.seek(time)
      return .none
    case .updateProgress(let currentTime, let duration):
      state.currentTime = currentTime
      state.duration = duration
      return .none
    }
  }
}
