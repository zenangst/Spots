import Cocoa
import Spots
import Brick

class MenuController: SpotsController, SpotsDelegate {

  convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
    self.spotsDelegate = self
    mockData()
  }

  func mockData() {
    let tableViewHeight = 40
    let meta = ["separator" : false, "tintColor" : "EF7C19"]
    let mainItems: [[String : AnyObject]] = [
      ["title" : "Browse", "subtitle" : "", "image" : "iconBrowse", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Activity", "subtitle" : "", "image" : "iconActivity", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Radio", "subtitle" : "", "image" : "iconRadio", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta]
    ]
    let yourMusicItems: [[String : AnyObject]] = [
      ["title" : "Songs", "subtitle" : "", "image" : "iconSongs", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Albums", "subtitle" : "", "image" : "iconAlbums", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Artists", "subtitle" : "", "image" : "iconArtists", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Stations", "subtitle" : "", "image" : "playlist", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta]
    ]
    let playlistItems: [[String : AnyObject]] = [
      ["title" : "Discover Weekly", "subtitle" : "by Spotify", "image" : "iconMyMusic", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Feels like 2016 Pt. 4", "subtitle" : "by Vadym Markov", "image" : "iconMyMusic", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Spots Demo", "subtitle" : "", "image" : "iconMyMusic", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "Starred", "subtitle" : "", "image" : "iconMyMusic", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta],
      ["title" : "New discoveries", "subtitle" : "", "image" : "iconMyMusic", "kind" : "list", "size" : ["width" : 120, "height" : tableViewHeight], "meta": meta]
    ]

    reload([
      "components" : [
        [
          "title" : "Main",
          "kind" : "grid",
          "span" : 1,
          "items" : mainItems,
          "meta" : [
            "titleFontSize" : 11,
            "titleLeftMargin" : 10
          ]
        ],
        [
          "title" : "Your Music",
          "kind" : "grid",
          "span" : 1,
          "items" : yourMusicItems,
          "meta" : [
            "titleFontSize" : 11,
            "titleLeftMargin" : 10
          ]
        ],
        [
          "title" : "Playlists",
          "kind" : "grid",
          "span" : 1,
          "items" : playlistItems,
          "meta" : [
            "titleFontSize" : 11,
            "titleLeftMargin" : 10
          ]
        ]
      ]
      ])
  }
}

extension MenuController {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    deselectAllExcept(spot)
  }
}
