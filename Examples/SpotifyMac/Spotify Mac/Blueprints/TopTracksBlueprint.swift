import Spots
import Sugar
import Brick
import Tailor

struct TopTracksBlueprint: BlueprintContainer {

  static let key = "top-tracks"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "top-tracks",
      requests: [(
        request: nil,
        rootKey: "tracks",
        spotIndex: 0,
        adapter: { json in
          var list = [Item]()
          for (index, item) in json.enumerated() {

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

            let viewModel = Item(
              title: item.resolve(keyPath: "name") ?? "",
              subtitle: "by \(subtitle)",
              image: item.resolve(keyPath: "album.images.0.url") ?? "",
              kind: "track",
              action: "preview",
              size: CGSize(width: 200, height: 50),
              meta: [
                "duration" : duration,
                "album-fragments" : albumFragments,
                "artist-fragments" : artistFragments,
                "album-urn" : albumURN,
                "artist-urn" : artistURN,
                "fragments" : ["preview" : item.resolve(keyPath: "preview_url") ?? ""],
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
            "title" : "Top Tracks",
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
            ]
          ]
        ]
      ]
    )
  }
}
