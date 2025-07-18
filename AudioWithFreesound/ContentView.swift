//
//  ContentView.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation

struct ContentView: View {
  let store: StoreOf<AppReducer>
  var body: some View {
    let searchSoundStore = store.scope(state: \.searchSound, action: AppAction.searchSound)
    let playSoundStore = store.scope(state: \.playSound, action: AppAction.playSound)
    ZStack {
      SearchSoundsView(store: searchSoundStore)
      VStack{
        Spacer()
        MiniPlayerView(sliderValue: .constant(10), store: playSoundStore)
      }
    }
  }
}

#Preview {
  let environment = SearchSoundsEnvironment(searchSoundsRequest: dummySearchSoundsEffect)
  let reducer = AppReducer()
  let store = Store(initialState: AppState(), reducer: { reducer })

  ContentView(store: store)
}
