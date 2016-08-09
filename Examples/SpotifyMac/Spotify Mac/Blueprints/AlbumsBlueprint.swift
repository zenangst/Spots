import Spots
import Sugar
import Brick
import Tailor

struct AlbumsBlueprint: BlueprintContainer {

  static let key = "albums"
  static var drawing: Blueprint {
    return Blueprint(
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
                "title" : item.resolve(keyPath: "album.name") ?? "",
                "image" : item.resolve(keyPath: "album.images.0.url") ?? ""
              ]

              let model = ViewModel(
                title: item.resolve(keyPath: "album.name") ?? "",
                image: item.resolve(keyPath: "album.images.0.url") ?? "",
                action: "album:\(item.resolve(keyPath: "album.id") ?? "")",
                kind: "album",
                size: CGSize(width: 180, height: 180),
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
            "title" : "Saved albums",
            "kind" : Component.Kind.Grid.rawValue,
            "items" : [
              "title" : "Loading..."
            ],
            "meta" : [
              GridSpot.Key.layout : GridSpot.LayoutType.Left.rawValue,
            ]
          ]
        ]
      ]
    )
  }
}
