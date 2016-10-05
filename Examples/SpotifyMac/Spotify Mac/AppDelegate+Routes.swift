import Compass
import AVFoundation
import Brick
import Sugar

extension AppDelegate {

  static func navigate(_ urn: String, fragments: [String : Any] = [:]) {
    let stringURL = "\(Compass.scheme)\(urn)"
    guard let appDelegate = NSApplication.shared().delegate as? AppDelegate,
      let url = URL(string: stringURL) else { return }

    appDelegate.handleURL(url, fragments: fragments)
  }

  func registerURLScheme() {
    NSAppleEventManager.shared().setEventHandler(self,
                                                                  andSelector: #selector(handle(_:replyEvent:)),
                                                                  forEventClass: AEEventClass(kInternetEventClass),
                                                                  andEventID: AEEventID(kAEGetURL))

    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      LSSetDefaultHandlerForURLScheme("spots" as CFString, bundleIdentifier as CFString)
    }
  }

  func handleURL(_ url: URL, parameters: [String : Any] = [:], fragments: [String : Any] = [:]) {

    if url.absoluteString.hasPrefix("spots://callback") {
      spotsSession.auth(url as NSURL)
      return
    }

    guard let location = Compass.parse(url, payload: fragments) else { return }
    let route = location.path
    let arguments = location.arguments

//    Compass.parse(url, payload: fragments) { route, arguments, fragments in

      self.detailController.fragments = fragments
      var newBlueprint: Blueprint? = nil

      switch route {
      case "forward":
        break
      case "back":
        guard let last = self.history.popLast() else { return }
        self.detailController.removeGradientSublayers()
        AppDelegate.navigate(last, fragments: ["skipHistory" : true])
      case "preview":
        let cacheDirectories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)

        guard let stringURL = fragments["preview"] as? String,
          let url = NSURL(string: stringURL),
          let cacheDirectory = cacheDirectories.first
          else { return }

        if let player = self.player {
          player.stop()
          self.player = nil
        }

        dispatch(queue: .interactive) {
          guard let data = NSData(contentsOf: url as URL), let lastPath = url.lastPathComponent else { return }

          do {
            let filePath = "\(cacheDirectory)/no.hyper.Spotify-Mac/\(lastPath)"
            data.write(toFile: filePath, atomically: true)

            let player = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: filePath) as URL)

            player.volume = 0.0
            self.player = player
            dispatch {
              self.volumeTimer?.invalidate()
              self.volumeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(AppDelegate.volumeFadeIn), userInfo: nil, repeats: true)

              self.volumeTimer?.fire()
              self.player?.play()
            }
          } catch { NSLog("error: \(error)") }
        }
      case "artist:{artist_id}":
        guard let artistBlueprint = blueprints["artist"],
        let artistID = arguments["artist_id"] else { return }
        var blueprint = artistBlueprint

        blueprint.cacheKey = "artist:\(artistID)"

        blueprint.requests.append(
          (
            request: ArtistAlbums(artistID: artistID),
            rootKey: "albums",
            spotIndex: 1,
            adapter: { json in
              var list = [Item]()
              for item in json {
                let duration = item.resolve(keyPath: "duration_ms") ?? 0
                let albumURN = "album:\(item.resolve(keyPath: "album.id") ?? "")"
                let artistURN = "artist:\(item.resolve(keyPath: "artists.0.id") ?? "")"
                let meta: [String : Any] = [
                  "album-urn" : albumURN,
                  "artist-urn" : artistURN,
                  "duration" : duration,
                  "separator" : true,
                  "fragments": [
                    "title": item.resolve(keyPath: "name") ?? "",
                    "image": item.resolve(keyPath: "images.0.url") ?? "",
                    ]
                  ]

                let viewModel = Item(
                  title: item.resolve(keyPath: "name") ?? "",
                  image: item.resolve(keyPath: "images.0.url") ?? "",
                  kind: "album",
                  action: "album:\(item.resolve(keyPath: "id") ?? "")",
                  size: CGSize(width: 180, height: 180),
                  meta: meta
                )
                list.append(viewModel)
              }
              return list
            }
          )
        )

        blueprint.requests.append(
          (
            request: ArtistTopTracks(artistID: artistID),
            rootKey: "tracks",
            spotIndex: 2,
            adapter: { json in
              var list = [Item]()

              for (index, item) in json.enumerated() {
                let albumFragments: [String : String] = [
                  "title" : item.resolve(keyPath: "album.name") ?? "",
                  "image" : item.resolve(keyPath: "album.images.0.url") ?? "",
                  "preview" : item.resolve(keyPath: "preview_url") ?? ""
                ]

                let artistFragments: [String : String] = [
                  "title" : item.resolve(keyPath: "artists.0.name") ?? "",
                  "image" : item.resolve(keyPath: "artists.0.images.0.url") ?? "",
                  "artist-id" : item.resolve(keyPath: "artists.0.id") ?? ""
                ]

                let duration = item.resolve(keyPath: "duration_ms") ?? 0
                let subtitle = item.resolve(keyPath: "artists.0.name") ?? ""
                let albumURN = "album:\(item.resolve(keyPath: "album.id") ?? "")"
                let artistURN = "artist:\(item.resolve(keyPath: "artists.0.id") ?? "")"

                let meta: [String : Any] = [
                  "album-urn" : albumURN,
                  "artist-urn" : artistURN,
                  "duration" : duration,
                  "album-fragments" : albumFragments,
                  "artist-fragments" : artistFragments,
                  "fragments" : ["preview" : item.resolve(keyPath: "preview_url") ?? ""],
                  "trackNumber" : "\(index + 1).",
                  "separator" : true
                ]

                let viewModel = Item(
                  title: item.resolve(keyPath: "name") ?? "",
                  subtitle: "by \(subtitle)",
                  image: item.resolve(keyPath: "album.images.0.url") ?? "",
                  kind: "track",
                  action: "preview",
                  size: CGSize(width: 200, height: 50),
                  meta: meta
                )
                list.append(viewModel)
              }

              return list
            }
          )
        )

        blueprint.requests.append(
          (
            request: ArtistRelatedArtists(artistID: artistID),
            rootKey: "artists",
            spotIndex: 3,
            adapter: { json in
              var list = [Item]()
              for item in json {

                var description = ""
                if let followers: Int = item.resolve(keyPath: "followers.total") {
                  description += "Followers: \(followers)\n"
                }

                if let genres = item["genres"] as? [String] , !genres.isEmpty {
                  description += "Genres: \(genres.joined(separator: ","))\n"
                }

                if let popularity: Int = item.resolve(keyPath: "popularity") {
                  description += "Popularity: \(popularity)\n"
                }

                let viewModel = Item(
                  title: item.resolve(keyPath: "name") ?? "",
                  image: item.resolve(keyPath: "images.0.url") ?? "",
                  kind: "artist",
                  action: "artist:\(item.resolve(keyPath: "id") ?? "")",
                  size: CGSize(width: 180, height: 180),
                  meta: [
                    "fragments" : [
                      "title" : item.resolve(keyPath: "name") ?? "",
                      "image" : item.resolve(keyPath: "images.0.url") ?? "",
                      "description" : description
                    ],
                    "separator" : true
                  ]
                )
                list.append(viewModel)
              }

              return list
            }
          )
        )

        newBlueprint = blueprint
      case "topArtists":
        guard let topTrackBlueprint = blueprints["top-artists"] else { return }
        if let _ = self.detailController.blueprint , fragments["skipHistory"] == nil {
          self.history.append("topArtists")
        }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "artists")
        newBlueprint = blueprint
      case "topTracks":
        guard let topTrackBlueprint = blueprints["top-tracks"] else { return }
        if let _ = self.detailController.blueprint , fragments["skipHistory"] == nil {
          self.history.append("topTracks")
        }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "tracks")
        newBlueprint = blueprint
      case "album:{album_id}":
        guard let albumID = arguments["album_id"],
          let albumBlueprint = blueprints["album"] else { return }

        var blueprint = albumBlueprint
        blueprint.cacheKey("album:\(albumID)")
        blueprint.requests[0].request = AlbumRequest(albumID: albumID)
        newBlueprint = blueprint
      case "albums":
        newBlueprint = blueprints[route]
      case "browse":
        newBlueprint = blueprints[route]
      case "category:{category_id}":
        guard let categoryID = arguments["category_id"],
          let categoryBlueprint = blueprints["category"] else { return }
        var blueprint = categoryBlueprint
        blueprint.cacheKey("category:\(categoryID)")
        blueprint.requests[0].request = CategoryRequest(categoryID: categoryID)
        newBlueprint = blueprint
      case "following":
        newBlueprint = blueprints[route]
      case "playlists":
        newBlueprint = blueprints[route]
      case "playlist:{user_id}:{playlist_id}":
        guard let userID = arguments["user_id"],
          let playlistID = arguments["playlist_id"],
          let playlistBlueprint = blueprints["playlist"] else { return }

        var blueprint = playlistBlueprint
        blueprint.cacheKey("playlist:\(userID):\(playlistID)")
        blueprint.requests[0].request = PlaylistRequest(userID: userID, playlistID: playlistID)
        newBlueprint = blueprint
      case "songs":
        newBlueprint = blueprints[route]
      default: break
      }

      if let newBlueprint = newBlueprint {
        self.evaluateBlueprint(newBlueprint, fragments: fragments)
      }
//    }
  }

  func evaluateBlueprint(_ newBlueprint: Blueprint, fragments: [String : Any]) {
    if let currentBlueprint = detailController.blueprint , fragments["skipHistory"] == nil {
      self.history.append(currentBlueprint.cacheKey)
    }

    if newBlueprint.cacheKey != detailController.blueprint?.cacheKey {
      detailController.blueprint = newBlueprint
    }
  }

  func handle(_ event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
    if let stringURL = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
      let url = URL(string: stringURL) {
      handleURL(url)
    }
  }

  func volumeFadeIn() {
    guard let player = player else { return }

    if player.volume <= 1.0 {
      player.volume += 0.1
    } else {
      volumeTimer?.invalidate()
    }
  }
}
