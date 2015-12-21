import Spots
import Fakery
import Sugar

class FavoritesController: SpotsController {

  static let faker = Faker()

  convenience init(title: String) {
    let favorites = Component(span: 3)
    self.init(spot: GridSpot(favorites, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5))
    self.title = title

    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 11)
      self?.update(closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }
  }

  static func generateItem(index: Int, kind: String = "topic") -> ListItem {
    let item = ListItem(title: faker.commerce.department(),
      kind: kind,
      image: faker.internet.image(width: 125, height: 160) + "?type=avatar&id=\(index)")

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
