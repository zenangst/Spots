import Cocoa
import Spots
import Brick
import Cocoa
import Sugar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: Window!

  var toolbar: Toolbar?
  var menuController = SpotsController(cacheKey: "menu-cache")

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    ListSpot.views["list"] = TableViewCell.self
    GridSpot.grids["list"] = GridListItem.self
    GridSpot.grids["grid"] = GridSpotItem.self
    GridSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["carousel"] = GridSpotItem.self
    CarouselSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["list"] = GridListItem.self
    CarouselSpot.grids["hero"] = HeroGridItem.self

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
    let featuredItems: [[String : AnyObject]] = [
      ["title" : "Show me love",
        "subtitle" : "Sam Feldt",
        "image" : "http://streamd.hitparade.ch/cdimages/sam_feldt_feat_kimberly_anne-show_me_love_s.jpg",
        "kind" : "featured",
        "size" : ["width" : 255, "height" : 325]
      ],
      ["title" : "Hotel Cabana",
        "subtitle" : "Naughty Boy",
        "image" : "http://www.hotel-r.net/im/hotel/es/hotel-cabana-2.jpg",
        "kind" : "featured",
        "size" : ["width" : 255, "height" : 325],
        "meta" : ["useAsBackground" : true]
      ],
      ["title" : "Random Access Memories",
        "subtitle" : "Daft Punk",
        "image" : "https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg",
        "kind" : "featured",
        "size" : ["width" : 255, "height" : 325]
      ],
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "featured",
        "size" : ["width" : 255, "height" : 325]
      ]
    ]
    let featuredItems2: [[String : AnyObject]] = [
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "featured",
        "size" : ["width" : 200, "height" : 250]
      ],
      ["title" : "Plastic Beach",
        "subtitle" : "Gorillaz",
        "image" : "http://www.vblurpage.com/images/gorillaz_plastic_digital_cover_big.jpg",
        "kind" : "featured",
        "size" : ["width" : 200, "height" : 250]
      ],
      ["title" : "Halcyon",
        "subtitle" : "Ellie Goulding",
        "image" : "http://vignette1.wikia.nocookie.net/elliegoulding-pedia/images/8/8c/Ellie_Goulding_-_Halcyon_Days_Deluxe.png/revision/latest?cb=20140311065123",
        "kind" : "featured",
        "size" : ["width" : 200, "height" : 250]
      ],
      ["title" : "Show me love",
        "subtitle" : "Sam Feldt",
        "image" : "http://streamd.hitparade.ch/cdimages/sam_feldt_feat_kimberly_anne-show_me_love_s.jpg",
        "kind" : "featured",
        "size" : ["width" : 200, "height" : 250]
      ],
      ["title" : "Hotel Cabana",
        "subtitle" : "Naughty Boy",
        "image" : "http://www.hotel-r.net/im/hotel/es/hotel-cabana-2.jpg",
        "kind" : "featured",
        "size" : ["width" : 200, "height" : 250]
      ],
    ]

    let height = 50
    let featuredItems3: [[String : AnyObject]] = [
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "list",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Plastic Beach",
        "subtitle" : "Gorillaz",
        "image" : "http://www.vblurpage.com/images/gorillaz_plastic_digital_cover_big.jpg",
        "kind" : "list",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Halcyon",
        "subtitle" : "Ellie Goulding",
        "image" : "http://vignette1.wikia.nocookie.net/elliegoulding-pedia/images/8/8c/Ellie_Goulding_-_Halcyon_Days_Deluxe.png/revision/latest?cb=20140311065123",
        "kind" : "list",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Hotel Cabana",
        "subtitle" : "Naughty Boy",
        "image" : "http://www.hotel-r.net/im/hotel/es/hotel-cabana-2.jpg",
        "kind" : "list",
        "size" : ["width" : 255, "height" : height]
      ],
      ["title" : "Show me love",
        "subtitle" : "Sam Feldt",
        "image" : "http://streamd.hitparade.ch/cdimages/sam_feldt_feat_kimberly_anne-show_me_love_s.jpg",
        "kind" : "list",
        "size" : ["width" : 255, "height" : height]
      ],
      ["title" : "Random Access Memories",
        "subtitle" : "Daft Punk",
        "image" : "https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg",
        "kind" : "list",
        "size" : ["width" : 255, "height" : height]
      ]
    ]

    menuController.spotsDelegate = self
    menuController.reload([
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

    let spotsController = SpotsController(cacheKey: "main-screen-cache")
    spotsController.spotsDelegate = self

    //            "gradientColor1" : "000000",
    //            "gradientColor2" : "111111",


    spotsController.reload([
      "components" : [
        [
          "title" : "Featured albums",
          "kind" : "carousel",
          "items" : featuredItems,
          "meta" : [
            "insetTop" : 20.0,
            "insetBottom" : 10.0,
            "insetLeft" : 10.0,
            "insetRight" : 10.0,
            "itemSpacing" : 10.0,
            "lineSpacing" : 10.0,
            "dynamicBackground" : true
          ]
        ],
        [
          "title" : "Top albums in Norway",
          "kind" : "carousel",
          "items" : featuredItems2,
          "meta" : [
            "insetTop" : 20.0,
            "insetLeft" : 10.0,
            "insetRight" : 10.0,
            "itemSpacing" : 10.0,
            "lineSpacing" : 10.0
          ]
        ],
        ["kind" : "grid",
          "span" : 1,
          "title" : "Recently played",
          "items" : featuredItems3,
          "meta" : [
            "insetTop" : 20.0,
            "insetLeft" : 10.0,
            "insetRight" : 10.0
          ]
        ]
      ]
      ])
    let splitView = MainSplitView(leftView: menuController.view,
                                  rightView: spotsController.view)

    toolbar = Toolbar(identifier: "main-toolbar")
    window.toolbar = toolbar
    window.contentView = splitView
    window.becomeKeyWindow()
  }
}

extension AppDelegate: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {

    menuController.deselectAllExcept(spot)

    NSLog("item: \(item)")
  }
}
