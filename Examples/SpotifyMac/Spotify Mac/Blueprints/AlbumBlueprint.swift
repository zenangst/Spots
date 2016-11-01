import Spots
import Sugar
import Brick
import Tailor

struct AlbumBlueprint: BlueprintContainer {

  static let key = "album"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "album",
      requests: [(
        request: nil,
        rootKey: "tracks",
        spotIndex: 1,
        adapter: { json in
          var list = [Item]()
          for (index, item) in json.enumerated() {
            let albumFragments: [String : String] = [
              "title" : item.resolve(keyPath: "track.album.name") ?? "",
              "image" : item.resolve(keyPath: "track.album.images.0.url") ?? "",
              "preview" : item.resolve(keyPath: "track.preview_url") ?? ""
            ]

            let artistFragments: [String : String] = [
              "title" : item.resolve(keyPath: "artists.0.name") ?? "",
              "image" : item.resolve(keyPath: "artists.0.images.0.url") ?? "",
              "artist-id" : item.resolve(keyPath: "artists.0.id") ?? ""
            ]

            let albumURN = "album:\(item.resolve(keyPath: "album.id") ?? "")"
            let artistURN = "artist:\(item.resolve(keyPath: "artists.0.id") ?? "")"

            let duration = item.resolve(keyPath: "duration_ms") ?? 0
            let subtitle = item.resolve(keyPath: "artists.0.name") ?? ""
            let meta: [String : Any] = [
              "duration" : duration,
              "album-fragments" : albumFragments,
              "artist-fragments" : artistFragments,
              "album-urn" : albumURN,
              "artist-urn" : artistURN,
              "fragments" : ["preview" : item.resolve(keyPath: "preview_url") ?? ""],
              "trackNumber" : "\(index + 1).",
              "separator" : true
            ]

            let viewModel = Item(
              title: item.resolve(keyPath: "name") ?? "",
              subtitle: "by \(subtitle)",
              image: "iconMyMusic",
              kind: "track",
              action: "preview",
              size: CGSize(width: 200, height: 50),
              meta: meta
            )
            list.append(viewModel)
          }
          return list
        }
        )],
      fragmentHandler: { fragments, controller in
        let headerModel = Item(
          title: fragments.resolve(keyPath:"title") ?? "",
          subtitle: fragments.resolve(keyPath:"description") ?? "",
          image: fragments.resolve(keyPath:"image") ?? "",
          kind : "header",
          size: CGSize(width: 700, height: 135)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .none) {
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
              ListSpot.Key.contentInsetsLeft : 0,
              ListSpot.Key.contentInsetsRight : 0
            ]
          ],
          [
            "kind" : "list",
            "meta" : [
              "double-click" : true,
              ListSpot.Key.contentInsetsLeft : 25,
              ListSpot.Key.contentInsetsRight : 20
            ]
          ]
        ]
      ]
    )
  }
}
