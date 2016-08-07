import Spots
import Sugar
import Brick
import Tailor

struct PlaylistsBlueprint: BlueprintContainer {

  static let key = "playlists"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "playlists",
      requests: [
        (
          request: PlaylistsRequest(),
          rootKey: "items",
          spotIndex: 0,
          adapter: { json in
            var viewModels = [ViewModel]()
            for item in json {
              let owner = item.path("owner.id") ?? ""
              let playlistID = item.property("id") ?? ""
              let viewModel = ViewModel(
                title: item.property("name") ?? "",
                image : item.path("images.0.url") ?? "",
                action: "playlist:\(owner):\(playlistID)",
                kind: "featured",
                size: CGSize(width: 180, height: 255),
                meta: [
                  "fragments" : [
                    "title" : item.property("name") ?? "",
                    "image" : item.path("images.0.url") ?? ""
                  ]
                ]
              )

              viewModels.append(viewModel)
            }

            return viewModels
          }
        )
      ],
      template: [
        "components" : [
          [
            "title" : "Playlists",
            "kind" : Component.Kind.Grid.rawValue,
            "meta" : [
              GridSpot.Key.layout : GridSpot.LayoutType.Left.rawValue,
            ]
          ]
        ]
      ]
    )
  }
}
