import Spots
import Sugar
import Brick
import Tailor

struct PlaylistsBlueprint: BlueprintContainer {

  static let key = "playlists"
  static var drawing: Blueprint {
    let template = [
      "components" : [
        [
          "title" : "Playlists",
          "kind" : Component.Kind.Grid.rawValue,
          "meta" : [
            GridSpot.Key.layout : GridSpot.LayoutType.left.rawValue,
          ]
        ]
      ]
    ]

    return Blueprint(
      cacheKey: "playlists",
      requests: [
        (
          request: PlaylistsRequest(),
          rootKey: "items",
          spotIndex: 0,
          adapter: { json in
            var viewModels = [Item]()
            for item in json {
              let owner = item.resolve(keyPath: "owner.id") ?? ""
              let playlistID = item.resolve(keyPath: "id") ?? ""
              let viewModel = Item(
                title: item.resolve(keyPath: "name") ?? "",
                image : item.resolve(keyPath: "images.0.url") ?? "",
                kind: "featured",
                action: "playlist:\(owner):\(playlistID)",
                size: CGSize(width: 180, height: 255),
                meta: [
                  "fragments" : [
                    "title" : item.resolve(keyPath: "name") ?? "",
                    "image" : item.resolve(keyPath: "images.0.url") ?? ""
                  ]
                ]
              )

              viewModels.append(viewModel)
            }

            return viewModels
          }
        )
      ],
      template: template
    )
  }
}
