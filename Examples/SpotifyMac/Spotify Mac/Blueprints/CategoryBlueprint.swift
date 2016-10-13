import Spots
import Sugar
import Brick
import Tailor

struct CategoryBlueprint: BlueprintContainer {

  static let key = "category"
  static var drawing: Blueprint {
    return Blueprint(cacheKey: "", requests: [(
      request: nil,
      rootKey: "playlists",
      spotIndex: 0,
      adapter: { json in
        var viewModels = [Item]()
        for item in json {
          let owner = item.resolve(keyPath: "owner.id") ?? ""
          let playlistID = item.resolve(keyPath: "id") ?? ""
          let meta: [String : Any] = [
            "separator" : false,
            "fragments" : [
              "title" : item.resolve(keyPath: "name") ?? "",
              "image" : item.resolve(keyPath: "images.0.url") ?? ""
            ]
          ]

          let viewModel = Item(
            title: item.resolve(keyPath: "name") ?? "",
            subtitle: "by " + owner,
            image: item.resolve(keyPath: "images.0.url") ?? "",
            kind: "album",
            action: "playlist:\(owner):\(playlistID)",
            size: CGSize(width: 180, height: 180),
            meta: meta
          )
          viewModels.append(viewModel)
        }
        return viewModels
      }
      )], template: [
        "components" : [
          [
            "kind" : Component.Kind.Grid.rawValue,
            "meta" : [
              GridSpot.Key.layout : GridSpot.LayoutType.Left.rawValue,
            ]
          ]
        ]
      ])
  }
}
