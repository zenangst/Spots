import Spots
import Sugar
import Brick
import Tailor

struct PlaylistBlueprint: BlueprintContainer {

  static let key = "playlist"
  static var drawing: Blueprint {
    return Blueprint(cacheKey: "", requests: [(
      request: nil,
      rootKey: "tracks",
      spotIndex: 1,
      adapter: { json in
        var list = [ViewModel]()
        for (index, item) in json.enumerate() {
          let subtitle = item.path("track.artists.0.name") ?? ""

          let albumFragments: [String : String] = [
            "title" : item.path("track.album.name") ?? "",
            "image" : item.path("track.album.images.0.url") ?? "",
            "preview" : item.path("track.preview_url") ?? ""
          ]

          let artistFragments: [String : String] = [
            "title" : item.path("track.artists.0.name") ?? "",
            "image" : item.path("track.artists.0.images.0.url") ?? "",
            "artist-id" : item.path("track.artists.0.id") ?? ""
          ]

          let duration = item.path("track.duration_ms") ?? 0
          let preview = item.path("track.preview_url") ?? ""
          let meta: [String : AnyObject] = [
            "fragments" : ["preview" : preview],
            "album-urn" : "album:\(item.path("track.album.id") ?? "")",
            "artist-urn" : "artist:\(item.path("track.artists.0.id") ?? "")",
            "duration" : duration,
            "album-fragments" : albumFragments,
            "artist-fragments" : artistFragments,
            "trackNumber" : "\(index + 1).",
            "separator" : true
          ]

          let viewModel = ViewModel(
            title: item.path("track.name") ?? "",
            subtitle: "by \(subtitle)",
            image: item.path("track.album.images.0.url") ?? "",
            action: "preview",
            kind: "track",
            size: CGSize(width: 200, height: 50),
            meta: meta
          )
          list.append(viewModel)
        }
        return list
      }
      )], fragmentHandler: { fragments, controller in
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
      },template: [
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
            "title" : "Songs",
            "kind" : "list",
            "meta" : [
              "doubleClick" : true,
              ListSpot.Key.contentInsetsLeft : 25.0,
              ListSpot.Key.contentInsetsRight : 25.0,
              GridSpot.Key.minimumInteritemSpacing : 0.0,
              GridSpot.Key.minimumLineSpacing : 0.0,
              ListSpot.Key.titleLeftInset : 25
            ]
          ]
        ]
      ]
    )
  }
}
