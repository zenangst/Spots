import Spots
import Fakery
import Sugar

class FavoritesController: SpotsController {

  static let faker = Faker()

  convenience init(title: String) {
    let favorites = Component(span: 3)
    let spots: [Spotable] = [
      GridSpot(favorites, top: 10, left: 5, bottom: 20, right: 5, itemSpacing: 5)
    ]

    self.init(spots: spots, refreshable: false)
    self.title = title

    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 11)
      self?.updateSpotAtIndex(0, closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }
  }

  static func generateItem(index: Int, kind: String = "topic") -> ListItem {
    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    let item = ListItem(title: faker.commerce.department(),
      kind: kind,
      image: "http://lorempixel.com/125/160?type=avatar&id=\(index)",
      meta: ["media" : mediaStrings])

    return item
  }

  static func generateItems(from: Int, to: Int, kind: String = "topic") -> [ListItem] {
    var items = [ListItem]()
    for i in from...from+to {
      autoreleasepool({
        items.append(generateItem(i))
      })
    }
    return items
  }
}
