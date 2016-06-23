import Cocoa
import Spots
import Brick
import Cocoa
import Sugar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    ListSpot.views["list"] = TableViewCell.self
    GridSpot.grids["grid"] = GridSpotItem.self
    GridSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["carousel"] = GridSpotItem.self
    CarouselSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["hero"] = HeroGridItem.self

    let leftViewItems: [[String : AnyObject]] = [
      ["title" : "Browse", "subtitle" : "", "image" : "https://cdn2.iconfinder.com/data/icons/windows-8-metro-style/512/open_in_browser.png", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Activity", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Radio", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Songs", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Albums", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Artists", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Stations", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Local files", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]]
    ]
    let featuredItems: [[String : AnyObject]] = [
      ["title" : "Hotel Cabana",
        "subtitle" : "Naughty Boy",
        "image" : "http://www.hotel-r.net/im/hotel/es/hotel-cabana-2.jpg",
        "kind" : "featured",
        "size" : ["width" : 250, "height" : 300]
      ],
      ["title" : "Show me love",
        "subtitle" : "Sam Feldt",
        "image" : "http://streamd.hitparade.ch/cdimages/sam_feldt_feat_kimberly_anne-show_me_love_s.jpg",
        "kind" : "featured",
        "size" : ["width" : 250, "height" : 300]
      ],
      ["title" : "Random Access Memories",
        "subtitle" : "Daft Punk",
        "image" : "https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg",
        "kind" : "featured",
        "size" : ["width" : 250, "height" : 300]
      ]
    ]
    let featuredItems2: [[String : AnyObject]] = [
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : 175]
      ],
      ["title" : "Plastic Beach",
        "subtitle" : "Gorillaz",
        "image" : "http://www.vblurpage.com/images/gorillaz_plastic_digital_cover_big.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : 175]
      ],
      ["title" : "Halcyon",
        "subtitle" : "Ellie Goulding",
        "image" : "http://vignette1.wikia.nocookie.net/elliegoulding-pedia/images/8/8c/Ellie_Goulding_-_Halcyon_Days_Deluxe.png/revision/latest?cb=20140311065123",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : 175]
      ]
    ]

    let height = 50
    let featuredItems3: [[String : AnyObject]] = [
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Plastic Beach",
        "subtitle" : "Gorillaz",
        "image" : "http://www.vblurpage.com/images/gorillaz_plastic_digital_cover_big.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Halcyon",
        "subtitle" : "Ellie Goulding",
        "image" : "http://vignette1.wikia.nocookie.net/elliegoulding-pedia/images/8/8c/Ellie_Goulding_-_Halcyon_Days_Deluxe.png/revision/latest?cb=20140311065123",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Sing me to sleep",
        "subtitle" : "Alan Walker",
        "image" : "https://artistxite.co.uk/imgcache/album/005/426/005426145_500.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Plastic Beach",
        "subtitle" : "Gorillaz",
        "image" : "http://www.vblurpage.com/images/gorillaz_plastic_digital_cover_big.jpg",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ],
      ["title" : "Halcyon",
        "subtitle" : "Ellie Goulding",
        "image" : "http://vignette1.wikia.nocookie.net/elliegoulding-pedia/images/8/8c/Ellie_Goulding_-_Halcyon_Days_Deluxe.png/revision/latest?cb=20140311065123",
        "kind" : "featured",
        "size" : ["width" : 175, "height" : height]
      ]
    ]

    let menuController = SpotsController(cacheKey: "menu-cache")
    menuController.spotsDelegate = self
    menuController.reload([
      "components" : [
        [
          "kind" : "list",
          "items" : leftViewItems
        ]
      ]
      ])
    let backgroundLayer = CALayer()
    backgroundLayer.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor
    menuController.spotsScrollView.layer = backgroundLayer

    let spotsController = SpotsController(cacheKey: "main-screen-cache")
    spotsController.spotsDelegate = self
    spotsController.reload([
      "components" : [
        ["kind" : "carousel",
          "span" : 1,
          "items" : [[
            "image" : "http://orig12.deviantart.net/e67c/f/2011/267/1/7/album_covers_wallpaper_by_brunomonteiro91-d4ariv0.jpg",
            "kind" : "hero",
            "size" : ["height" : 325]
          ]]
        ],
        ["kind" : "carousel",
          "items" : featuredItems,
          "meta" : [
            "itemSpacing" : 10.0,
            "lineSpacing" : 10.0,
          ]
        ],
        ["kind" : "grid",
          "items" : featuredItems2,
          "meta" : [
            "itemSpacing" : 0.0,
            "lineSpacing" : 0.0,
          ]
        ],
        ["kind" : "list",
          "items" : featuredItems3,
          "meta" : [
            "itemSpacing" : 0.0,
            "lineSpacing" : 0.0,
          ]
        ]
      ]
      ])
    let splitView = MainSplitView(leftView: menuController.view, rightView: spotsController.view)
    splitView.layer = CALayer()
    splitView.layer?.backgroundColor = NSColor.blackColor().CGColor
    splitView.wantsLayer = true

    let toolbar = NSToolbar()
    toolbar.visible = true

    window.titleVisibility = NSWindowTitleVisibility.Hidden
    window.toolbar = toolbar
    window.styleMask = NSTitledWindowMask |
      NSUnifiedTitleAndToolbarWindowMask |
      NSClosableWindowMask |
      NSMiniaturizableWindowMask |
    NSResizableWindowMask

    window.contentView = splitView
    window.becomeKeyWindow()
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}

extension AppDelegate: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    NSLog("item: \(item)")
  }
}
