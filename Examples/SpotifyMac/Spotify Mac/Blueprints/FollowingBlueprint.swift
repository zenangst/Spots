import Spots
import Sugar
import Brick
import Tailor

struct FollowingBlueprint: BlueprintContainer {

  static let key = "following"
  static var drawing: Blueprint {
    return Blueprint(
      cacheKey: "following",
      requests: [(
        request: FollowingRequest(),
        rootKey: "artists",
        spotIndex: 0,
        adapter: { json in
          var viewModels = [Item]()
          for item in json {

            var description = ""

            if let followers: Int = item.resolve(keyPath: "followers.total") {
              description += "Followers: \(followers)\n"
            }

            if let genres = item["genres"] as? [String] , !genres.isEmpty {
              description += "Genres: \(genres.joined(separator: ","))\n"
            }

            if let popularity: Int = item.resolve(keyPath: "popularity") {
              description += "Popularity: \(popularity)\n"
            }

            viewModels.append(Item(
              title : item.resolve(keyPath: "name") ?? "",
              image : item.resolve(keyPath: "images.1.url") ?? "",
              kind: "artist",
              action : "artist:\(item.resolve(keyPath: "id") ?? "")",
              size: CGSize(width: 160, height: 160),
              meta: [
                "fragments" : [
                  "title" : item.resolve(keyPath: "name") ?? "",
                  "image" : item.resolve(keyPath: "images.1.url") ?? "",
                  "description" : description
                ]
              ]
              ))
          }

          viewModels.sort { $0.title < $1.title }

          return viewModels
      })],
      template: [
        "components" : [
          [
            "title" : "Following",
            "kind" : Component.Kind.Grid.rawValue,
            "meta" : [
              GridableMeta.Key.sectionInsetTop : 10.0,
              GridableMeta.Key.sectionInsetRight : 10.0,
              GridSpot.Key.minimumInteritemSpacing : 5.0,
              GridSpot.Key.minimumLineSpacing : 5.0,
            ]
          ]
        ]
      ]
    )
  }
}
