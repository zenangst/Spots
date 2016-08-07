import Spots
import Sugar
import Brick
import Tailor

struct TopArtistsBlueprint: BlueprintContainer {

  static let key = "top-artists"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "top-artists",
      requests: [(
        request: nil,
        rootKey: "artists",
        spotIndex: 0,
        adapter: { json in
          var viewModels = [ViewModel]()
          for item in json {

            var description = ""
            let followers: Int = item.path("followers.total") ?? 0
            if followers > 0 {
              description += "Followers: \(followers)\n"
            }

            if let genres = item["genres"] as? [String] where !genres.isEmpty {
              description += "Genres: \(genres.joinWithSeparator(","))\n"
            }

            if let popularity = item["popularity"] as? Int {
              description += "Popularity: \(popularity)\n"
            }

            viewModels.append(ViewModel(
              title : item.property("name") ?? "",
              image : item.path("images.2.url") ?? "",
              action: "artist:\(item.property("id") ?? "")",
              kind: "artist",
              size: CGSize(width: 180, height: 180),
              meta: ["fragments" : [
                "title" : item.property("name") ?? "",
                "image" : item.path("images.1.url") ?? "",
                "description" : description
                ]]
              ))
          }

          viewModels.sortInPlace { $0.title < $1.title }

          return viewModels
      })],
      template: [
        "components" : [
          [
            "title" : "Top Artists",
            "kind" : Component.Kind.Grid.rawValue,
            "items" : [
              "title" : "Loading..."
            ]
          ]
        ]
      ]
    )
  }
}
