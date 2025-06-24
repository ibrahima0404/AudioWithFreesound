//
//  Endpoint.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 19/06/2025.
//
import Foundation

struct SoundEndpoint {
  private static let baseURL = URL(string: "https://freesound.org")!
  private static let apiToken = "zRLqXZb1vm0B7bnH51AxRsF9GaVaiANj3OMY1vAn"

  let path: String
  let queryItems: [URLQueryItem]

  var url: URL? {
    var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
    components?.path = path
    components?.queryItems = queryItems
    return components?.url
  }

  init(path: String, queryItems: [URLQueryItem] = []) {
    self.path = path
    self.queryItems = queryItems
  }
}

extension SoundEndpoint {
  static func search(matching query: String) -> SoundEndpoint {
    SoundEndpoint(
      path: "/apiv2/search/text",
      queryItems: [
        URLQueryItem(name: "query", value: "tag:music \(query)"),
        URLQueryItem(name: "filter", value: "duration:[60 TO *]"),
        URLQueryItem(name: "token", value: apiToken)
      ]
    )
  }

  static func requestSound(id: Int) -> SoundEndpoint {
    SoundEndpoint(
      path: "/apiv2/sounds/\(id)",
      queryItems: [
        URLQueryItem(name: "token", value: apiToken)
      ]
    )
  }
}
