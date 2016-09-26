import Spots
import Sugar
import Brick
import Tailor

struct SongsBlueprint: BlueprintContainer {

  static let key = "songs"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "songs",
      requests: [(
        request: TracksRequest(),
        rootKey: "tracks",
        spotIndex: 0,
        adapter: { json in
          var list = [Item]()
          for (index, item) in json.enumerate() {
            let subtitle = item.resolve(keyPath: "track.artists.0.name") ?? ""
            let viewModel = Item(
              title: item.resolve(keyPath: "track.name") ?? "",
              subtitle: "by \(subtitle)",
              action: "preview",
              image: item.resolve(keyPath: "track.album.images.0.url") ?? "",
              kind: "track",
              size: CGSize(width: 200, height: 50),
              meta: [
                "fragments" : ["preview" : item.resolve(keyPath: "track.preview_url") ?? ""],
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
            "title" : "Saved songs",
            "kind" : "list",
            "items" : [
              "title" : "Loading..."
            ],
            "meta" : [
              "doubleClick" : true,
              "insetRight" : 10.0,
              "insetBottom" : 20.0,
            ]
          ]
        ]
      ]
    )
  }
}
