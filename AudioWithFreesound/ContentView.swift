//
//  ContentView.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
  let store: StoreOf<SearchSoundReducer>
  var body: some View {
    SearchSoundsView(store: store)
  }
}

#Preview {
  let environment = SearchSoundsEnvironment(searchSoundsRequest: dummySearchSoundsEffect)
  let reducer = SearchSoundReducer(environment: environment)
  let store = Store(initialState: SearchSoundState(), reducer: { reducer })

  ContentView(store: store)
}
