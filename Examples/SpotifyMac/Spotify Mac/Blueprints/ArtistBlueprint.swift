import Spots
import Sugar
import Brick
import Tailor
import Malibu

struct ArtistBlueprint: BlueprintContainer {

  static let key = "artist"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "artist",
      requests: [],
      fragmentHandler: { fragments, controller in

        let image: String = fragments.resolve(keyPath:"image") ?? ""

        if let artistID: String = fragments.resolve(keyPath:"artist-id") where image.isEmpty {
          let ride = Malibu.networking("api").GET(ArtistRequest(artistID: artistID))
          ride.validate()
            .toJSONDictionary()
            .done { json in

              guard let firstItem = controller.spot(0, Listable.self)?.component.items.first else { return }
              var newItem = firstItem
              newItem.image = json.resolve(keyPath: "images.0.url") ?? ""
              controller.updateIfNeeded(spotAtIndex: 0, items: [newItem], withAnimation: .None) {
                controller.cache()
              }
          }
        }

        let headerModel = ViewModel(
          title: fragments.resolve(keyPath:"title") ?? "",
          image: fragments.resolve(keyPath:"image") ?? "",
          subtitle: fragments.resolve(keyPath:"description") ?? "",
          kind : "header",
          size: CGSize(width: 700, height: 135)
        )

        controller.updateIfNeeded(spotAtIndex: 0, items: [headerModel], withAnimation: .None) {
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
            "title" : "Top Albums",
            "kind" : Component.Kind.Carousel.rawValue,
            "meta" : [
              "insetBottom":  30.0,
              "insetRight" : 10.0,
            ]
          ],
          ["kind" : Component.Kind.List.rawValue,
            "span" : 3,
            "title" : "Top Tracks",
            "meta" : [
              "insetRight" : 10.0,
              "insetBottom" : 30.0,
              "itemSpacing" : 0.0,
              "doubleClick" : true,
            ]
          ],
          ["kind" : Component.Kind.Carousel.rawValue,
            "title" : "Related artist",
            "meta" : [
              GridableMeta.Key.sectionInsetBottom: 20,
              "insetRight" : 10.0,
              "lineSpacing" : 10.0
            ]
          ],
        ]
      ]
    )
  }

}
