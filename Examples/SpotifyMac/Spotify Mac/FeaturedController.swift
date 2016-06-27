import Spots
import Brick

class FeaturedController: SpotsController, SpotsDelegate {

  convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
    self.spotsDelegate = self
    mockData()
  }

  func mockData() {
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

    reload([
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

  }
}

extension FeaturedController {
  
  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    deselectAllExcept(spot)
  }
}
