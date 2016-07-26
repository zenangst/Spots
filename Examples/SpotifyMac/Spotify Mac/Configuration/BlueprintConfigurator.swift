import Spots
import Sugar
import Brick
import Tailor

struct BlueprintConfigurator: Configurator {

  func configure() {

    blueprints["artist"] = Blueprint(
      cacheKey: "artist",
      requests: [],
      fragmentHandler: { fragments, controller in
        let headerModel = ViewModel(
          title: fragments.property("title") ?? "",
          image: fragments.property("image") ?? "",
          subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tristique metus in lectus accumsan dictum. Aenean at dolor vestibulum, faucibus justo et, feugiat diam. Integer laoreet quis ligula ac lobortis. Quisque nec venenatis enim. Duis sit amet ex eget mi interdum auctor. Etiam dignissim ullamcorper elementum. Quisque ac viverra neque, vitae tincidunt tellus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce quis erat eget odio bibendum malesuada. Curabitur eget quam nisl. Quisque sit amet mattis ipsum. Donec elementum ante quis pulvinar sollicitudin.",
          kind : "header",
          size: CGSize(width: 700, height: 185)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
          controller.cache()
        }
      },
      template: [
        "components" : [
          [
            "kind" : "list",
            "size" : [
              "width" : 200.0,
              "height" : 315.0
            ],
            "meta" : [
              "layout" : "left",
              "insetTop" : 20.0,
              "insetLeft" : 0.0,
              "insetRight" : 0.0,
              "insetBottom" : 0.0,
            ]
          ],
          [
            "title" : "Top albums",
            "kind" : Component.Kind.Carousel.string,
            "meta" : [
              "itemSpacing" : 10.0,
              "lineSpacing" : 10.0,
              "insetTop" : 20.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
            ]
          ],
          ["kind" : Component.Kind.List.string,
            "span" : 3,
            "title" : "Top tracks",
            "meta" : [
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 10.0,
              "doubleClick" : true,
            ]
          ],
          ["kind" : Component.Kind.Carousel.string,
            "title" : "Related artist",
            "meta" : [
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 10.0,
              "itemSpacing" : 10.0,
              "lineSpacing" : 10.0
            ]
          ],
        ]
      ]
    )

    blueprints["top-artists"] = Blueprint(
      cacheKey: "top-artists",
      requests: [(
        request: nil,
        rootKey: "artists",
        spotIndex: 0,
        adapter: { json in
          var viewModels = [ViewModel]()
          for item in json {
            viewModels.append(ViewModel(
              title : item.property("name") ?? "",
              image : item.array("images")?[2].property("url") ?? "",
              action: "artist:\(item.property("id") ?? "")",
              kind: "artist",
              size: CGSize(width: 160, height: 160),
              meta: ["fragments" : [
                "title" : item.property("name") ?? "",
                "image" : item.array("images")?[1].property("url") ?? "",
                ]]
              ))
          }

          return viewModels
      })],
      template: [
        "components" : [
          [
            "title" : "Top Artists",
            "kind" : "grid",
            "items" : [
              "title" : "Loading..."
            ],
            "meta" : [
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 10.0,
              "itemSpacing" : 10.0,
              "lineSpacing" : 10.0,
              "titleFontSize" : 15,
              "titleTopInset" : 30,
              "titleBottomInset" : 30,
              "titleLeftInset" : 25
            ]
          ]
        ]
      ]
    )

    blueprints["top-tracks"] = Blueprint(
      cacheKey: "top-tracks",
      requests: [(
        request: nil,
        rootKey: "tracks",
        spotIndex: 0,
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
                "trackNumber" : "\(index + 1).",
                "separator" : true
              ]
            )
            list.append(viewModel)
          }

          return list
        }
        )],
      template: [
        "components" : [
          [
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 20.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 0.0,
              "titleFontSize" : 15,
              "titleTopInset" : 30,
              "titleLeftInset" : 25
            ]
          ]
        ]
      ]
    )

    blueprints["album"] = Blueprint(
      cacheKey: "album",
      requests: [(
        request: nil,
        rootKey: "tracks",
        spotIndex: 1,
        adapter: { json in
          var list = [ViewModel]()
          for (index, item) in json.enumerate() {
            let subtitle = item.array("artists")?.first?.property("name") ?? ""
            let viewModel = ViewModel(
              title: item.property("name") ?? "",
              subtitle: "by \(subtitle)",
              image: "iconMyMusic",
              action: "preview",
              kind: "track",
              size: CGSize(width: 200, height: 50),
              meta: [
                "fragments" : ["preview" : item.property("preview_url") ?? ""],
                "trackNumber" : "\(index + 1).",
                "separator" : true
              ]
            )
            list.append(viewModel)
          }
          return list
        }
      )],
      fragmentHandler: { fragments, controller in
        let headerModel = ViewModel(
          title: fragments.property("title") ?? "",
          image: fragments.property("image") ?? "",
          subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tristique metus in lectus accumsan dictum. Aenean at dolor vestibulum, faucibus justo et, feugiat diam. Integer laoreet quis ligula ac lobortis. Quisque nec venenatis enim. Duis sit amet ex eget mi interdum auctor. Etiam dignissim ullamcorper elementum. Quisque ac viverra neque, vitae tincidunt tellus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce quis erat eget odio bibendum malesuada. Curabitur eget quam nisl. Quisque sit amet mattis ipsum. Donec elementum ante quis pulvinar sollicitudin.",
          kind : "header",
          size: CGSize(width: 700, height: 185)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
          controller.cache()
        }
      },
      template: [
        "components" : [
          [
            "kind" : "list",
            "size" : [
              "width" : 200.0,
              "height" : 315.0
            ],
            "meta" : [
              "layout" : "left",
              "insetTop" : 20.0,
              "insetLeft" : 0.0,
              "insetRight" : 0.0,
              "insetBottom" : 10.0,
            ]
          ],
          [
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
              "insetLeft" : 25.0,
              "insetRight" : 20.0,
              "insetTop" : 0.0,
              "insetBottom" : 0.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 0.0,
              "titleFontSize" : 15
            ]
          ]
        ]
      ]
    )

    blueprints["albums"] = Blueprint(
      cacheKey: "albums",
      requests: [
      (
        request: AlbumsRequest(),
        rootKey: "albums",
        spotIndex: 0,
        adapter: { json in
          var viewModels = [ViewModel]()
          for item in json {
            let fragments: [String : String] = [
              "title" : item.path("album")?.property("name") ?? "",
              "image" : item.path("album")?.array("images")?.first?.property("url") ?? ""
            ]

            let model = ViewModel(
              title: item.path("album")?.property("name") ?? "",
              image: item.path("album")?.array("images")?.first?.property("url") ?? "",
              action: "album:\(item.path("album")?.property("id") ?? "")",
              kind: "album",
              size: CGSize(width: 200, height: 200),
              meta: [
                "separator" : true,
                "fragments": fragments
              ]
            )
            viewModels.append(model)
          }

          return viewModels
        }
      )],
      template: [
        "components" : [
          [
            "title" : "Albums",
            "kind" : "grid",
            "items" : [
              "title" : "Loading..."
            ],
            "meta" : [
              "layout" : "left",
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 10.0,
              "itemSpacing" : 5.0,
              "lineSpacing" : 5.0,
              "titleFontSize" : 15,
              "titleTopInset" : 30,
              "titleBottomInset" : 30,
              "titleLeftInset" : 25
            ]
          ]
        ]
      ]
    )

    blueprints["following"] = Blueprint(
    cacheKey: "following",
    requests: [(
      request: FollowingRequest(),
      rootKey: "artists",
      spotIndex: 0,
      adapter: { json in
        var viewModels = [ViewModel]()
        for item in json {
          viewModels.append(ViewModel(
            title : item.property("name") ?? "",
            image : item.array("images")?[1].property("url") ?? "",
            action : "artist:\(item.property("id") ?? "")",
            kind: "artist",
            size: CGSize(width: 160, height: 160),
            meta: [
              "fragments" : [
                "title" : item.property("name") ?? "",
                "image" : item.array("images")?[1].property("url") ?? "",
              ]
            ]
          ))
        }

        return viewModels
      })],
    template: [
      "components" : [
        [
          "title" : "Following",
          "kind" : "grid",
          "meta" : [
            "insetTop" : 30.0,
            "insetLeft" : 10.0,
            "insetRight" : 10.0,
            "insetBottom" : 10.0,
            "itemSpacing" : 5.0,
            "lineSpacing" : 5.0,
            "titleFontSize" : 15,
            "titleTopInset" : 30,
            "titleBottomInset" : 30,
            "titleLeftInset" : 25
          ]
        ]
      ]
      ]
    )

    blueprints["songs"] = Blueprint(
      cacheKey: "songs",
      requests: [(
        request: TracksRequest(),
        rootKey: "tracks",
        spotIndex: 0,
        adapter: { json in
          var list = [ViewModel]()
          for (index, item) in json.enumerate() {
            let subtitle = item.path("track")?.array("artists")?.first?.property("name") ?? ""
            let viewModel = ViewModel(
              title: item.path("track")?.property("name") ?? "",
              subtitle: "by \(subtitle)",
              action: "preview",
              image: item.path("track.album")?.array("images")?.first?.property("url") ?? "",
              kind: "track",
              size: CGSize(width: 200, height: 50),
              meta: [
                "fragments" : ["preview" : item.path("track")?.property("preview_url") ?? ""],
                "trackNumber" : "\(index + 1).",
                "separator" : true
              ]
            )
            list.append(viewModel)
          }

          return list
        }
        )],
      template: [
        "components" : [
          [
            "kind" : "list",
            "items" : [
              "title" : "Loading..."
            ],
            "meta" : [
              "doubleClick" : true,
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 20.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 0.0,
              "titleFontSize" : 15,
              "titleTopInset" : 30,
              "titleBottomInset" : 30,
              "titleLeftInset" : 25
            ]
          ]
        ]
      ]
    )

    blueprints["category"] = Blueprint(cacheKey: "", requests: [(
      request: nil,
      rootKey: "playlists",
      spotIndex: 0,
      adapter: { json in
        var viewModels = [ViewModel]()
        for item in json {
          let owner = item.path("owner")?.property("id") ?? ""
          let playlistID = item.property("id") ?? ""
          let viewModel = ViewModel(
            title: item.property("name") ?? "",
            subtitle: "by " + owner,
            image: item.array("images")?.first?.property("url") ?? "",
            action: "playlist:\(owner):\(playlistID)",
            kind: "featured",
            size: CGSize(width: 200, height: 225),
            meta: [
              "separator" : false,
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
      )], template: [
      "components" : [
        [
          "title" : "Category",
          "kind" : "grid",
          "meta" : [
            "layout" : "left",
            "insetTop" : 20.0,
            "insetLeft" : 20.0,
            "insetRight" : 20.0,
            "insetBottom" : 20.0,
            "itemSpacing" : 10.0,
            "lineSpacing" : 10.0,
            "titleFontSize" : 11,
            "titleLeftMargin" : 10
          ]
        ]
      ]
      ])

    blueprints["playlist"] = Blueprint(cacheKey: "", requests: [(
      request: nil,
      rootKey: "tracks",
      spotIndex: 1,
      adapter: { json in
        var list = [ViewModel]()
        for (index, item) in json.enumerate() {
          let subtitle = item.path("track")?.array("artists")?.first?.property("name") ?? ""
          let viewModel = ViewModel(
            title: item.path("track")?.property("name") ?? "",
            subtitle: "by \(subtitle)",
            image: item.path("track.album")?.array("images")?.first?.property("url") ?? "",
            action: "preview",
            kind: "track",
            size: CGSize(width: 200, height: 50),
            meta: [
              "fragments" : ["preview" : item.path("track")?.property("preview_url") ?? ""],
              "trackNumber" : "\(index + 1).",
              "separator" : true
            ]
          )
          list.append(viewModel)
        }
        return list
      }
      )], fragmentHandler: { fragments, controller in
        let headerModel = ViewModel(
          title: fragments.property("title") ?? "",
          image: fragments.property("image") ?? "",
          subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tristique metus in lectus accumsan dictum. Aenean at dolor vestibulum, faucibus justo et, feugiat diam. Integer laoreet quis ligula ac lobortis. Quisque nec venenatis enim. Duis sit amet ex eget mi interdum auctor. Etiam dignissim ullamcorper elementum. Quisque ac viverra neque, vitae tincidunt tellus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce quis erat eget odio bibendum malesuada. Curabitur eget quam nisl. Quisque sit amet mattis ipsum. Donec elementum ante quis pulvinar sollicitudin.",
          kind : "header",
          size: CGSize(width: 700, height: 185)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
          controller.cache()
        }
      },template: [
        "components" : [
          [
            "kind" : "list",
            "size" : [
              "width" : 200.0,
              "height" : 315.0
            ],
            "meta" : [
              "layout" : "left",
              "insetTop" : 20.0,
              "insetLeft" : 0.0,
              "insetRight" : 0.0,
              "insetBottom" : 10.0,
            ]
          ],
          [
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
              "insetLeft" : 25.0,
              "insetRight" : 20.0,
              "insetTop" : 0.0,
              "insetBottom" : 0.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 0.0,
              "titleFontSize" : 15
            ]
          ]
        ]
      ]
    )

    blueprints["browse"] = Blueprint(
      cacheKey: "browse",
      requests: [
        (
          request: FeaturedPlaylists(),
          rootKey: "playlists",
          spotIndex: 1,
          adapter: { json in
            var viewModels = [ViewModel]()
            for item in json {
              let owner = item.path("owner")?.property("id") ?? ""
              let playlistID = item.property("id") ?? ""
              let viewModel = ViewModel(
                title: item.property("name") ?? "",
                subtitle: "by " + owner,
                image: item.array("images")?.first?.property("url") ?? "",
                action: "playlist:\(owner):\(playlistID)",
                kind: "featured",
                size: CGSize(width: 250, height: 325),
                meta: [
                  "separator" : false,
                  "fragments" : [
                    "title" : item.property("name") ?? "",
                    "image" : item.array("images")?.first?.property("url") ?? ""
                  ]
                ]
              )
              viewModels.append(viewModel)
            }

            viewModels[0].meta["useAsBackground"] = true

            return viewModels
          }
        ),
        (
          request: NewReleasesRequest(),
          rootKey: "albums",
          spotIndex: 2,
          adapter: { json in

            var viewModels = [ViewModel]()

            for item in json {
              let fragments: [String : String] = [
                "title" : item.property("name") ?? "",
                "image" : item.array("images")?.first?.property("url") ?? ""
              ]

              let model = ViewModel(
                title: item.property("name") ?? "",
                image: item.array("images")?.first?.property("url") ?? "",
                action: "album:\(item.property("id") ?? "")",
                kind: "list",
                size: CGSize(width: 250, height: 44),
                meta: [
                  "separator" : true,
                  "fragments" : fragments
                ]
              )

              viewModels.append(model)
            }

            return viewModels
          }
        ),
        (
          request: CategoriesRequest(),
          rootKey: "categories",
          spotIndex: 3,
          adapter: { json in
            var viewModels = [ViewModel]()
            for item in json {
              let action = item.property("id") ?? ""
              let model = ViewModel(
                title: item.property("name") ?? "",
                image: item.array("icons")?.first?.property("url") ?? "",
                action: "category:\(action)",
                kind: "category",
                size: CGSize(width: 120, height: 120),
                meta: [
                  "separator" : false,
                  "fragments" : [
                    "title" : item.property("name") ?? "",
                    "image" : item.array("icons")?.first?.property("url") ?? ""
                  ]
                ]
              )
              viewModels.append(model)
            }
            return viewModels
          }
        )
      ],
      fragmentHandler: { fragments, controller in
        let headerModel = ViewModel(
          title: "Welcome to Spotify for the Mac",
          image: "http://i1.wp.com/fusion.net/wp-content/uploads/2015/06/150623-album-covers.png?resize=1600%2C900&quality=80&strip=all",
          subtitle: "Built with Spots",
          kind : "hero",
          size: CGSize(width: 700, height: 400)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
          controller.cache()
        }
      },
      template: [
        "components" : [
          [
            "kind" : Component.Kind.List.string,
            "span" : 1,
            "items" : [
              [
                "title" : "Welcome to Spotify for the Mac",
                "subtitle" : "Built with Spots",
                "image" : "http://i1.wp.com/fusion.net/wp-content/uploads/2015/06/150623-album-covers.png?resize=1600%2C900&quality=80&strip=all",
                "kind" : "hero",
                "size" : ["width" : 0.0, "height": 400]
              ]
            ],
            "meta" : [
              "insetTop" : 0.0,
              "insetLeft" : 0.0,
              "insetRight" : 0.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 0.0,
            ]
          ],
          [
            "title" : "Featured playlists",
            "kind" : Component.Kind.Carousel.string,
            "meta" : [
              "itemSpacing" : 10.0,
              "lineSpacing" : 10.0,
              "insetTop" : 10.0,
              "insetBottom" : 0.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "titleLeftMargin" : 20
            ]
          ],
          ["kind" : Component.Kind.Grid.string,
            "span" : 3,
            "title" : "New releases",
            "meta" : [
              "insetTop" : 10.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "itemSpacing" : 0.0,
              "lineSpacing" : 10.0,
              "titleLeftMargin" : 20,
              "layout" : "left"
            ]
          ],
          ["kind" : Component.Kind.Grid.string,
            "title" : "Categories",
            "meta" : [
              "layout" : "left",
              "insetTop" : 30.0,
              "insetLeft" : 10.0,
              "insetRight" : 10.0,
              "insetBottom" : 10.0,
              "itemSpacing" : 10.0,
              "lineSpacing" : 10.0,
              "titleLeftMargin" : 20
            ]
          ],
        ]
      ]
    )
  }
}
