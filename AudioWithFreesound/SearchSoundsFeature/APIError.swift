//
//  APIError.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//

enum APIError: Error, Equatable {
  case decodingFailed(message: String)
  case downloadFailed
}
