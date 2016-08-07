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
          var list = [ViewModel]()
          for (index, item) in json.enumerate() {

            let albumFragments: [String : String] = [
              "title" : item.path("album.name") ?? "",
              "image" : item.path("album.images.0.url") ?? "",
              "preview" : item.path("preview_url") ?? ""
            ]

            let artistFragments: [String : String] = [
              "title" : item.path("artists.0.name") ?? "",
              "image" : item.path("artists.0.images.0.url") ?? "",
              "artist-id" : item.path("artists.0.id") ?? ""
            ]

            let duration = item.property("duration_ms") ?? 0
            let subtitle = item.path("artists.0.name") ?? ""
            let albumURN = "album:\(item.path("album.id") ?? "")"
            let artistURN = "artist:\(item.path("artists.0.id") ?? "")"

            let viewModel = ViewModel(
              title: item.property("name") ?? "",
              subtitle: "by \(subtitle)",
              action: "preview",
              image: item.path("album.images.0.url") ?? "",
              kind: "track",
              size: CGSize(width: 200, height: 50),
              meta: [
                "duration" : duration,
                "album-fragments" : albumFragments,
                "artist-fragments" : artistFragments,
                "album-urn" : albumURN,
                "artist-urn" : artistURN,
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
