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
    initialState: AppState(),
    reducer: { AppReducer()
    })

  var body: some Scene {
    WindowGroup {
      ContentView(store: AudioWithFreesoundApp.store)
    }
  }
}
