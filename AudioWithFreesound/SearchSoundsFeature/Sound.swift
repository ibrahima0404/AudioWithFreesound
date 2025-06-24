//
//  Sound.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//
import Foundation

struct Sound: Equatable, Decodable, Identifiable, Hashable {
  let id: Int
  let name: String
}

struct SoundMetadata: Decodable, Equatable {
  let id: Int
  let name: String
  let duration: Double
  let previews: [String: String]
}
