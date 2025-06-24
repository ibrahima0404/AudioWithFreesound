//
//  SearchSoundsEffects.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 24/06/2025.
//

import Foundation
import ComposableArchitecture

func searchSoundsEffect(decoder: JSONDecoder, query: String) async -> Result<SoundAPIResponse, APIError> {
  guard let url = SoundEndpoint.search(matching: query).url else {
    print("Couldn't build url")
    return .failure(.downloadFailed)
  }

  do {
    let (data, _) = try await URLSession.shared.data(from: url)
    let repos = try JSONDecoder().decode(SoundAPIResponse.self, from: data)
    return .success(repos)
  } catch {
    print("Error decoding data: \(error)")
    return .failure(.decodingFailed(message: error.localizedDescription))
  }
}

func dummySearchSoundsEffect(decoder: JSONDecoder, query: String) async -> Result<SoundAPIResponse, APIError> {
  let dummySounds = {
    var sounds = [Sound]()
    for i in 1...10 {
      sounds.append(Sound(id: i, name: "Sound \(i)"))
    }
    return sounds
  }()
  return Result.success(SoundAPIResponse(results: dummySounds))
}
