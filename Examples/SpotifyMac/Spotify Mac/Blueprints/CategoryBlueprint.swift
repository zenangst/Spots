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
          let viewModel = Item(
            title: item.resolve(keyPath: "name") ?? "",
            subtitle: "by " + owner,
            image: item.resolve(keyPath: "images.0.url") ?? "",
            action: "playlist:\(owner):\(playlistID)",
            kind: "album",
            size: CGSize(width: 180, height: 180),
            meta: [
              "separator" : false,
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
