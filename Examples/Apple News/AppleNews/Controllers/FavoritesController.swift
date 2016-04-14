import Spots
import Fakery
import Sugar
import Brick

class FavoritesController: SpotsController {

  static let faker = Faker()

  convenience init(title: String) {
    let favorites = Component(span: 3)
    self.init(spot: GridSpot(favorites, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5))
    self.title = title
  }

  static func generateItem(index: Int, kind: Cell = Cell.Topic) -> ViewModel {
    let item = ViewModel(
      title: faker.commerce.department(),
      kind: kind,
      image: faker.internet.image(width: 125, height: 160) + "?type=avatar&id=\(index)")

    return item
  }

  static func generateItems(from: Int, to: Int, kind: Cell = Cell.Topic) -> [ViewModel] {
    var items = [ViewModel]()
    for i in from...from+to {
      autoreleasepool { items.append(generateItem(i)) }
    }
    return items
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 11)
      self?.update { spot in
        spot.component.items = items
      }
    }
  }
}
