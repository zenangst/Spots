import Spots
import Sugar
import Brick
import Tailor

struct BrowseBlueprint: BlueprintContainer {

  static let key = "browse"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "browse",
      requests: [
        (
          request: FeaturedPlaylists(),
          rootKey: "playlists",
          spotIndex: 1,
          adapter: { json in
            var viewModels = [ViewModel]()
            for item in json {
              let owner = item.path("owner.id") ?? ""
              let playlistID = item.property("id") ?? ""
              let viewModel = ViewModel(
                title: item.property("name") ?? "",
                subtitle: "by " + owner,
                image: item.path("images.0.url") ?? "",
                action: "playlist:\(owner):\(playlistID)",
                kind: "featured",
                size: CGSize(width: 200, height: 275),
                meta: [
                  "separator" : false,
                  "fragments" : [
                    "title" : item.property("name") ?? "",
                    "image" : item.path("images.0.url") ?? ""
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
                "image" : item.path("images.0.url") ?? ""
              ]

              let model = ViewModel(
                title: item.property("name") ?? "",
                image: item.path("images.0.url") ?? "",
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
                image: item.path("icons.0.url") ?? "",
                action: "category:\(action)",
                kind: "category",
                size: CGSize(width: 120, height: 120),
                meta: [
                  "separator" : false,
                  "fragments" : [
                    "title" : item.property("name") ?? "",
                    "image" : item.path("icons.0.url") ?? ""
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
          title: "Spotify for macOS",
          subtitle: "Built with Spots",
          image: "http://i1.wp.com/fusion.net/wp-content/uploads/2015/06/150623-album-covers.png?resize=1600%2C900&quality=80&strip=all",
          kind : "hero",
          size: CGSize(width: 700, height: 250)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
          controller.cache()
        }
      },
      template: [
        "components" : [
          [
            "kind" : Component.Kind.List.rawValue,
            "span" : 1,
            "items" : [
              [
                "title" : "",
                "image" : "http://i1.wp.com/fusion.net/wp-content/uploads/2015/06/150623-album-covers.png?resize=1600%2C900&quality=80&strip=all",
                "kind" : "hero",
                "size" : ["width" : 0.0, "height": 250]
              ]
            ],
            "meta" : [
              ListSpot.Key.contentInsetsLeft : 0,
              ListSpot.Key.contentInsetsRight : 0
            ]
          ],
          [
            "title" : "Featured Playlists",
            "kind" : Component.Kind.Carousel.rawValue,
            "meta" : [
              GridableMeta.Key.sectionInsetRight : 10.0,
            ]
          ],
          ["kind" : Component.Kind.Grid.rawValue,
            "span" : 3,
            "title" : "New Releases",
            "meta" : [
              GridableMeta.Key.sectionInsetLeft : 10.0,
              GridableMeta.Key.sectionInsetRight : 0.0,
              GridSpot.Key.minimumInteritemSpacing : 0.0,
              GridSpot.Key.minimumLineSpacing : 0.0,
              GridSpot.Key.layout : GridSpot.LayoutType.Left.rawValue
            ]
          ],
          ["kind" : Component.Kind.Grid.rawValue,
            "title" : "Categories",
            "meta" : [
              GridSpot.Key.layout : GridSpot.LayoutType.Left.rawValue,
              GridableMeta.Key.sectionInsetLeft : 10.0,
              GridableMeta.Key.sectionInsetRight : 0.0,
              GridableMeta.Key.sectionInsetBottom : 10.0,
            ]
          ],
        ]
      ]
    )
  }
}
