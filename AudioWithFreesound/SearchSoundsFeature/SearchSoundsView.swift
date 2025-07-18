//
//  SearchSoundsView.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 24/06/2025.
//

import SwiftUI
import ComposableArchitecture

struct SearchSoundsView: View {
  @State private var searchText = ""
  let store: StoreOf<SearchSoundReducer>
  @State private var selectedSound: Sound?
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List(viewStore.retrievedSounds, id: \.self, selection: $selectedSound) { sound in
          Text(sound.name)
            .lineLimit(2)
        }
        .onChange(of: selectedSound) { oldValue, newValue in
          if let newValue {
            viewStore.send(.onSelect(newValue))
          }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { oldValue, newValue in
          viewStore.send(.search(newValue))
        }
        .navigationTitle("Rechercher des sons")
      }
    }
  }
}

#Preview {
  let reducer = SearchSoundReducer(
    environment: SearchSoundsEnvironment(
      searchSoundsRequest: dummySearchSoundsEffect
    ))

  let store = Store(
    initialState: SearchSoundState(),
    reducer: { reducer
    })

  SearchSoundsView(store: store)
}
