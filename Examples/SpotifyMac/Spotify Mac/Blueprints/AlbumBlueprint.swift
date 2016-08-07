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
          var list = [ViewModel]()
          for (index, item) in json.enumerate() {
            let albumFragments: [String : String] = [
              "title" : item.path("track.album.name") ?? "",
              "image" : item.path("track.album.images.0.url") ?? "",
              "preview" : item.path("track.preview_url") ?? ""
            ]

            let artistFragments: [String : String] = [
              "title" : item.path("artists.0.name") ?? "",
              "image" : item.path("artists.0.images.0.url") ?? "",
              "artist-id" : item.path("artists.0.id") ?? ""
            ]

            let albumURN = "album:\(item.path("album.id") ?? "")"
            let artistURN = "artist:\(item.path("artists.0.id") ?? "")"

            let duration = item.property("duration_ms") ?? 0
            let subtitle = item.path("artists.0.name") ?? ""
            let meta: [String : AnyObject] = [
              "duration" : duration,
              "album-fragments" : albumFragments,
              "artist-fragments" : artistFragments,
              "album-urn" : albumURN,
              "artist-urn" : artistURN,
              "fragments" : ["preview" : item.property("preview_url") ?? ""],
              "trackNumber" : "\(index + 1).",
              "separator" : true
            ]

            let viewModel = ViewModel(
              title: item.property("name") ?? "",
              subtitle: "by \(subtitle)",
              image: "iconMyMusic",
              action: "preview",
              kind: "track",
              size: CGSize(width: 200, height: 50),
              meta: meta
            )
            list.append(viewModel)
          }
          return list
        }
        )],
      fragmentHandler: { fragments, controller in
        let headerModel = ViewModel(
          title: fragments.property("title") ?? "",
          image: fragments.property("image") ?? "",
          subtitle: fragments.property("description") ?? "",
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
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
              ListSpot.Key.contentInsetsLeft : 25,
              ListSpot.Key.contentInsetsRight : 20
            ]
          ]
        ]
      ]
    )
  }
}
