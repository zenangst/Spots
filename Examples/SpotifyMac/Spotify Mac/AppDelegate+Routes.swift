import Compass
import AVFoundation
import Brick

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

      switch route {
      case "preview":
        let cacheDirectories = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)

        guard let stringURL = fragments["preview"] as? String,
          url = NSURL(string: stringURL),
          cacheDirectory = cacheDirectories.first
          else { return }

        if let player = self.player {
          //player.stop()
          self.player = nil
        }

        guard let data = NSData(contentsOfURL: url), lastPath = url.lastPathComponent else { return }

        do {
          let filePath = "\(cacheDirectory)/no.hyper.Spotify-Mac/\(lastPath)"
          data.writeToFile(filePath, atomically: true)
          let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath))
          self.player = player

          if !player.playing {
            player.volume = 0.0
            self.volumeFadeIn()
          }

          player.play()

        } catch { NSLog("error: \(error)") }
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
                let viewModel = ViewModel(
                  title: item.property("name") ?? "",
                  image: item.array("images")?.first?.property("url") ?? "",
                  action: "album:\(item.property("id") ?? "")",
                  kind: "album",
                  size: CGSize(width: 160, height: 180),
                  meta: [
                    "separator" : true,
                    "fragments": [
                      "title": item.property("name") ?? "",
                      "image": item.array("images")?.first?.property("url") ?? "",
                    ]
                  ]
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
                let subtitle = item.array("artists")?.first?.property("name") ?? ""
                let viewModel = ViewModel(
                  title: item.property("name") ?? "",
                  subtitle: "by \(subtitle)",
                  action: "preview",
                  image: item.path("album")?.array("images")?.first?.property("url") ?? "",
                  kind: "track",
                  size: CGSize(width: 200, height: 50),
                  meta: [
                    "fragments" : ["preview" : item.property("preview_url") ?? ""],
                    "trackNumber" : "\(index).",
                    "separator" : true
                  ]
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
                let viewModel = ViewModel(
                  title: item.property("name") ?? "",
                  action: "artist:\(item.property("id") ?? "")",
                  image: item.array("images")?.first?.property("url") ?? "",
                  kind: "artist",
                  size: CGSize(width: 160, height: 180),
                  meta: [
                    "fragments" : [
                      "title" : item.property("name") ?? "",
                      "image" : item.array("images")?.first?.property("url") ?? ""
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

        self.detailController.blueprint = blueprint
      case "topArtists":
        guard let topTrackBlueprint = blueprints["top-artists"] else { return }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "artists")
        self.detailController.blueprint = blueprint
      case "topTracks":
        guard let topTrackBlueprint = blueprints["top-tracks"] else { return }
        var blueprint = topTrackBlueprint
        blueprint.requests[0].request = TopRequest(type: "tracks")
        self.detailController.blueprint = blueprint
      case "album:{album_id}":
        guard let albumID = arguments["album_id"],
          albumBlueprint = blueprints["album"] else { return }

        var blueprint = albumBlueprint
        blueprint.cacheKey("album:\(albumID)")
        blueprint.requests[0].request = AlbumRequest(albumID: albumID)
        self.detailController.blueprint = blueprint
      case "albums":
        guard let blueprint = blueprints["albums"] else { return }
        self.detailController.blueprint = blueprint
      case "browse":
        guard let blueprint = blueprints["browse"] else { return }
        self.detailController.blueprint = blueprint
      case "category:{category_id}":
        guard let categoryID = arguments["category_id"],
          categoryBlueprint = blueprints["category"] else { return }
        var blueprint = categoryBlueprint
        blueprint.cacheKey("category:playlist:\(categoryID)")
        blueprint.requests[0].request = CategoryRequest(categoryID: categoryID)
        self.detailController.blueprint = blueprint
      case "following":
        guard let blueprint = blueprints["following"] else { return }
        self.detailController.blueprint = blueprint
      case "playlist:{user_id}:{playlist_id}":
        guard let userID = arguments["user_id"],
          playlistID = arguments["playlist_id"],
          playlistBlueprint = blueprints["playlist"] else { return }

        var blueprint = playlistBlueprint
        blueprint.cacheKey("playlist:\(userID):\(playlistID)")
        blueprint.requests[0].request = PlaylistRequest(userID: userID, playlistID: playlistID)
        self.detailController.blueprint = blueprint
      case "songs":
        guard let blueprint = blueprints["songs"] else { return }
        self.detailController.blueprint = blueprint
      default: break
      }
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
    if player.volume < 1.0 {
      player.volume += 0.1
      self.performSelector(#selector(AppDelegate.volumeFadeIn), withObject: nil, afterDelay: 0.2)
    }
  }
}
