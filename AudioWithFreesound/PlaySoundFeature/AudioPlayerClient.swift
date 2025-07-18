//
//  AudioPlayerClient.swift
//  AudioWithFreesound
//
//  Created by Ibrahima KH GUEYE on 23/06/2025.
//


import AVFoundation
import ComposableArchitecture
import Dependencies

struct AudioPlayerClient {
  var play: @Sendable (URL) -> Void
  var pause: @Sendable () -> Void
  var stop: @Sendable () -> Void
  var seek: @Sendable (Double) -> Void
  var observeProgress: @Sendable () -> AsyncStream<(Double, Double)>
  var observeDidFinishPlaying: @Sendable () -> AsyncStream<Void>
}

// MARK: - Dependency

extension DependencyValues {
  var audioPlayer: AudioPlayerClient {
    get { self[AudioPlayerClientKey.self] }
    set { self[AudioPlayerClientKey.self] = newValue }
  }
}

// MARK: - Actor encapsulation

private actor AudioPlayerController {
  let player = AVPlayer()
  var timeObserver: Any?
  var endObserver: Any?


  func play(url: URL) async {
    let shouldReplace = await MainActor.run {
      (player.currentItem?.asset as? AVURLAsset)?.url != url
    }

    if shouldReplace {
      await MainActor.run {
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
      }
    }

    await MainActor.run {
      player.play()
    }
  }

  func pause() {
    player.pause()
  }

  func stop() {
    player.pause()
    player.seek(to: .zero)
  }

  func seek(to seconds: Double) {
    let time = CMTime(seconds: seconds, preferredTimescale: 600)
    player.seek(to: time)
  }

  func observeProgress() -> AsyncStream<(Double, Double)> {
    AsyncStream { continuation in
      let token = player.addPeriodicTimeObserver(
        forInterval: CMTime(seconds: 1.0, preferredTimescale: 600),
        queue: .main
      ) { time in
        let current = time.seconds
        let total = self.player.currentItem?.duration.seconds ?? 1
        continuation.yield((current, total))
      }

      timeObserver = token

      continuation.onTermination = { _ in
        Task {
          if let token = await self.timeObserver {
            self.player.removeTimeObserver(token)
            await self.cleanup()
          }
        }
      }
    }
  }

  private func setEndObserver(_ observer: NSObjectProtocol?) {
    self.endObserver = observer
  }

  func observeEndOfPlayback() -> AsyncStream<Void> {
    AsyncStream { continuation in
      Task {

        let observer = await MainActor.run {
          NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
          ) { _ in
            continuation.yield(())
          }
        }

        self.setEndObserver(observer)

        continuation.onTermination = { _ in
          Task {
            if let observer = await self.endObserver {
              await MainActor.run {
                NotificationCenter.default.removeObserver(observer)
              }
              await self.setEndObserver(nil)
            }
          }
        }
      }
    }
  }

  private func cleanup() {
    if let token = timeObserver {
      player.removeTimeObserver(token)
      timeObserver = nil
    }
  }

}

// MARK: - implementation

enum AudioPlayerClientKey: DependencyKey {
  static let liveValue: AudioPlayerClient = {
    let controller = AudioPlayerController()

    return AudioPlayerClient(
      play: { url in
        Task { await controller.play(url: url) }
      },
      pause: {
        Task { await controller.pause() }
      },
      stop: {
        Task { await controller.stop() }
      },
      seek: { seconds in
        Task { await controller.seek(to: seconds) }
      },
      observeProgress: {
        AsyncStream { continuation in
          Task {
            for await value in await controller.observeProgress() {
              continuation.yield(value)
            }
          }
        }
      }, observeDidFinishPlaying: {
        AsyncStream { continuation in
          Task {
            for await _ in await controller.observeEndOfPlayback() {
              continuation.yield(())
            }
          }
        }
      }
    )
  }()
}
