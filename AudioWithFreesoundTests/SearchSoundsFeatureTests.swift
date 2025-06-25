//
//  SearchSoundsFeatureTests.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 25/06/2025.
//

@testable import AudioWithFreesound
import ComposableArchitecture
import XCTest

@MainActor
final class SearchSoundsFeatureTests: XCTestCase {
  let tesScheduler = DispatchQueue.test

  func testSearchSoundsFeature() async {
    let sounds: [Sound] = (try? await dummySearchSoundsEffect(decoder: JSONDecoder(), query: "drums").get().results) ?? []

    let store = TestStore(
      initialState: SearchSoundState(),
      reducer: { SearchSoundReducer(environment: SearchSoundsEnvironment(searchSoundsRequest: dummySearchSoundsEffect))
      })

    await store.send(.search("drums"))
    await tesScheduler.advance()

    await store.receive(.retrievedSounds(sounds)) { state in
      state.retrievedSounds = sounds
    }
  }
}
