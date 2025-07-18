//
//  PlaySoundEffects.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//

import Foundation
import ComposableArchitecture

func soundRequestEffects(decoder: JSONDecoder, id: Int) async -> Result<SoundMetadata, APIError> {
  guard let url = SoundEndpoint.requestSound(id: id).url else {
    print("Couldn't build url")
    return .failure(.downloadFailed)
  }

  do {
    let (data, _) = try await URLSession.shared.data(from: url)
    let soundMeta = try JSONDecoder().decode(SoundMetadata.self, from: data)
    return .success(soundMeta)
  } catch {
    print("Error decoding data: \(error)")
    return .failure(.decodingFailed(message: error.localizedDescription))
  }
}
