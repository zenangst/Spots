import Cocoa
import Spots
import Brick
import Malibu
import Sugar
import Compass
import Sugar

class ListController: SpotsController, SpotsDelegate, SpotsScrollDelegate {

  struct UI {
    static let main = 0
    static let yourMusic = 1
    static let playlists = 2
  }

  convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    var spots = stateCache.load()

    if spots.isEmpty {
    let size = ["height" : 40]
      let meta = ["separator" : false, "tintColor" : "EF7C19"]
      let mainItems: [[String : AnyObject]] = [
        [
          "title" : "Browse",
          "subtitle" : "",
          "action" : "browse",
          "image" : "iconBrowse",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Following",
          "action" : "following",
          "image" : "iconActivity",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Top Artists",
          "image" : "topArtists",
          "action" : "topArtists",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Top Tracks",
          "image" : "topTracks",
          "action" : "topTracks",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ]
      ]
      let yourMusicItems: [[String : AnyObject]] = [
        [
          "title" : "Songs",
          "action" : "songs",
          "image" : "iconSongs",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Albums",
          "action" : "albums",
          "image" : "iconAlbums",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ]
      ]

      spots = [
        "components" : [
          [
            "kind" : "list",
            "span" : 1,
            "items" : mainItems,
            "meta" : [
              "titleFontSize" : 11,
              "insetTop" : 0,
              "insetLeft" : 0,
              "insetRight" : 0
            ]
          ],
          [
            "title" : "Your Music".uppercaseString,
            "kind" : "list",
            "span" : 1,
            "items" : yourMusicItems,
            "meta" : [
              "titleFontSize" : 11,
              "insetTop" : 30.0,
              "insetLeft" : 0,
              "insetRight" : 0
            ]
          ],
          [
            "title" : "Playlists".uppercaseString,
            "kind" : "list",
            "span" : 1,
            "meta" : [
              "titleFontSize" : 11,
              "insetTop" : 30.0,
              "insetLeft" : 0,
              "insetRight" : 0
            ]
          ]
        ]
      ]
    }

    self.init(spots: Parser.parse(spots))
    self.stateCache = stateCache
    self.spotsDelegate = self
    self.spotsScrollDelegate = self
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    fetchPlaylists()
  }

  func fetchPlaylists() {
    Malibu.networking("api").GET(PlaylistsRequest())
      .validate()
      .toJSONDictionary()
      .done { json in
        guard let items = json["items"] as? JSONArray else { return }
        let viewModels = self.parse(items)
        self.updateIfNeeded(spotAtIndex: UI.playlists, items: viewModels) {
          self.cache()
        }
    }
  }

  private func parse(json: JSONArray) -> [ViewModel] {
    var viewModels = [ViewModel]()
    for item in json {
      let owner = (item["owner"] as? JSONDictionary)?["id"] as? String ?? ""
      let playlistID = item["id"] as? String ?? ""

      let viewModel = ViewModel(
        title: item["name"] as? String ?? "",
        image: "iconMyMusic",
        action: "playlist:\(owner):\(playlistID)",
        kind: "list",
        size: CGSize(width: 120, height: 40),
        meta: [
          "separator" : false,
          "tintColor" : "EF7C19",
          "fragments" : [
            "title" : item.property("name") ?? "",
            "image" : item.array("images")?.first?.property("url") ?? ""
          ]
        ]
      )

      viewModels.append(viewModel)
    }

    return viewModels
  }
}

extension ListController {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    deselectAllExcept(spot)

    guard let action = item.action else { return }

    AppDelegate.navigate(action, fragments: item.meta("fragments", [:]))
  }

  func spotDidReachEnd(completion: Completion) {
    let offset = spot(UI.playlists, Spotable.self)?.component.items.count ?? 0
    Malibu.networking("api").GET(PlaylistsRequest(offset: offset))
      .validate()
      .toJSONDictionary()
      .done { json in
        guard let items = json["items"] as? JSONArray else { return }
        let viewModels = self.parse(items)

        self.append(viewModels, spotIndex: UI.playlists, withAnimation: .Automatic)
        completion?()
    }
  }
}
