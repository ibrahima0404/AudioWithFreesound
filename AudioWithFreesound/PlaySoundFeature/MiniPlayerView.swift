//
//  MiniPlayerView.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 26/06/2025.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation

struct MiniPlayerView: View {
  @Binding var sliderValue: Double
  let store: StoreOf<PlaySoundReducer>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      if viewStore.selectedSound == nil {
        EmptyView()
      } else {
        VStack {
          HStack {
            Text(viewStore.soundPlaying?.name ?? "Unknown Sound")
              .lineLimit(1)
              .font(.headline)
            Spacer()
            Button {
              viewStore.send(viewStore.playerState == .playing ? .pause : .play)
            } label: {
              Image(viewStore.playerState == .playing ? "pause" : "play")
            }
          }
          .padding([.top, .leading, .trailing], 10)
          VStack(spacing: 2) {
            HStack {
              Text(formatTime(viewStore.currentTime))
                .font(.caption)
              Spacer()
              Text(formatTime(viewStore.duration))
                .font(.caption)
            }
            
            Slider(
              value: viewStore.binding(get: \.currentTime, send: PlaySoundAction.seek),
              in: 0...max(0, viewStore.duration)
            )
          }
          .padding([.bottom, .leading, .trailing], 10)
        }
        .frame(height: 100)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(20.0)
        .padding(10)
      }
    }
  }
  func formatTime(_ seconds: Double) -> String {
    let totalSeconds = Int(max(0, seconds))
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
  }
}

#Preview {
  let env = PlaySoundEnvironment(soundRequest: soundRequestEffects, audioClient: AudioPlayerClientKey.liveValue)
  let store = Store(initialState: PlaySoundState(), reducer: { PlaySoundReducer(environment: env) })
  MiniPlayerView(sliderValue: .constant(10), store: store)
}
