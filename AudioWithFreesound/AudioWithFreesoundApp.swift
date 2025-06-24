//
//  AudioWithFreesoundApp.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct AudioWithFreesoundApp: App {
  static let store = Store(
    initialState: SearchSoundState(),
    reducer: { SearchSoundReducer(environment: SearchSoundsEnvironment(searchSoundsRequest: searchSoundsEffect))
    })

  var body: some Scene {
    WindowGroup {
      ContentView(store: AudioWithFreesoundApp.store)
    }
  }
}
