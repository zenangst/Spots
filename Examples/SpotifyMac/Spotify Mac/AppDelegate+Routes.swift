import Compass
import AVFoundation
import Brick
import Sugar

extension AppDelegate {

  static func navigate(urn: String, fragments: [String : AnyObject] = [:]) {
    let stringURL = "\(Compass.scheme)\(urn)"
    guard let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate,
      url = NSURL(string: stringURL) else { return }

    appDelegate.handleURL(url, fragments: fragments)
  }

  func registerURLScheme() {
    NSAppleEventManager.sharedAppleEventManager().setEventHandler(self,
                                                                  andSelector: #selector(handle(_:replyEvent:)),
                                                                  forEventClass: AEEventClass(kInternetEventClass),
                                                                  andEventID: AEEventID(kAEGetURL))

    if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
      LSSetDefaultHandlerForURLScheme("spots", bundleIdentifier as CFString)
    }
  }

  func handleURL(url: NSURL, parameters: [String : AnyObject] = [:], fragments: [String : AnyObject] = [:]) {

    if url.absoluteString.hasPrefix("spots://callback") {
      spotsSession.auth(url)
      return
    }

    Compass.parse(url, fragments: fragments) { route, arguments, fragments in

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
        let cacheDirectories = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)

        guard let stringURL = fragments["preview"] as? String,
          url = NSURL(string: stringURL),
          cacheDirectory = cacheDirectories.first
          else { return }

        if let player = self.player {
          player.stop()
          self.player = nil
        }

        dispatch(queue: .Interactive) {
          guard let data = NSData(contentsOfURL: url), lastPath = url.lastPathComponent else { return }

          do {
            let filePath = "\(cacheDirectory)/no.hyper.Spotify-Mac/\(lastPath)"
            data.writeToFile(filePath, atomically: true)

            let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath))

            player.volume = 0.0
            self.player = player
            dispatch {
              self.volumeTimer?.invalidate()
              self.volumeTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(AppDelegate.volumeFadeIn), userInfo: nil, repeats: true)

              self.volumeTimer?.fire()
              self.player?.play()
            }
          } catch { NSLog("error: \(error)") }
        }
      case "artist:{artist_id}":
        guard let artistBlueprint = blueprints["artist"],
        artistID = arguments["artist_id"] else { return }
        var blueprint = artistBlueprint

        blueprint.cacheKey = "artist:\(artistID)"

        blueprint.requests.append(
          (
            request: ArtistAlbums(artistID: artistID),
            rootKey: "albums",
            spotIndex: 1,
            adapter: { json in
              var list = [ViewModel]()
              for item in json {
                let duration = item.resolve(keyPath: "duration_ms") ?? 0
                let albumURN = "album:\(item.resolve(keyPath: "album.id") ?? "")"
                let artistURN = "artist:\(item.resolve(keyPath: "artists.0.id") ?? "")"
                let meta: [String : AnyObject] = [
                  "album-urn" : albumURN,
                  "artist-urn" : artistURN,
                  "duration" : duration,
                  "separator" : true,
                  "fragments": [
                    "title": item.resolve(keyPath: "name") ?? "",
                    "image": item.resolve(keyPath: "images.0.url") ?? "",
                    ]
                  ]

                let viewModel = ViewModel(
                  title: item.resolve(keyPath: "name") ?? "",
                  image: item.resolve(keyPath: "images.0.url") ?? "",
                  action: "album:\(item.resolve(keyPath: "id") ?? "")",
                  kind: "album",
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
              var list = [ViewModel]()

              for (index, item) in json.enumerate() {
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

                let meta: [String : AnyObject] = [
                  "album-urn" : albumURN,
                  "artist-urn" : artistURN,
                  "duration" : duration,
                  "album-fragments" : albumFragments,
                  "artist-fragments" : artistFragments,
                  "fragments" : ["preview" : item.resolve(keyPath: "preview_url") ?? ""],
                  "trackNumber" : "\(index + 1).",
                  "separator" : true
                ]

                let viewModel = ViewModel(
                  title: item.resolve(keyPath: "name") ?? "",
                  subtitle: "by \(subtitle)",
                  action: "preview",
                  image: item.resolve(keyPath: "album.images.0.url") ?? "",
                  kind: "track",
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
              var list = [ViewModel]()
              for item in json {

                var description = ""
                if let followers: Int = item.resolve(keyPath: "followers.total") {
                  description += "Followers: \(followers)\n"
                }

                if let genres = item["genres"] as? [String] where !genres.isEmpty {
                  description += "Genres: \(genres.joinWithSeparator(","))\n"
                }

                if let popularity: Int = item.resolve(keyPath: "popularity") {
                  description += "Popularity: \(popularity)\n"
                }

                let viewModel = ViewModel(
                  title: item.resolve(keyPath: "name") ?? "",
                  action: "artist:\(item.resolve(keyPath: "id") ?? "")",
                  image: item.resolve(keyPath: "images.0.url") ?? "",
                  kind: "artist",
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
        if let _ = self.detailController.blueprint where fragments["skipHistory"] == nil {
          self.history.append("topArtists")
        }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "artists")
        newBlueprint = blueprint
      case "topTracks":
        guard let topTrackBlueprint = blueprints["top-tracks"] else { return }
        if let _ = self.detailController.blueprint where fragments["skipHistory"] == nil {
          self.history.append("topTracks")
        }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "tracks")
        newBlueprint = blueprint
      case "album:{album_id}":
        guard let albumID = arguments["album_id"],
          albumBlueprint = blueprints["album"] else { return }

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
          categoryBlueprint = blueprints["category"] else { return }
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
          playlistID = arguments["playlist_id"],
          playlistBlueprint = blueprints["playlist"] else { return }

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
    }
  }

  func evaluateBlueprint(newBlueprint: Blueprint, fragments: [String : AnyObject]) {
    if let currentBlueprint = detailController.blueprint where fragments["skipHistory"] == nil {
      self.history.append(currentBlueprint.cacheKey)
    }

    if newBlueprint.cacheKey != detailController.blueprint?.cacheKey {
      detailController.blueprint = newBlueprint
    }
  }

  func handle(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
    if let stringURL = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue,
      url = NSURL(string: stringURL) {
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
