import Spots
import Sugar
import Fakery

class ForYouController: SpotsController, SpotsDelegate {

  static let faker = Faker()

  convenience init(title: String) {
    let component = Component()
    let feedSpot = ListSpot(component: component)
    self.init(spot: feedSpot)

    self.title = title
    spotsDelegate = self
    spotsScrollDelegate = self
    spotsRefreshDelegate = self

    dispatch(queue: .Interactive) { [weak self] in
      let items = ForYouController.generateItems(0, to: 10)
      self?.update { spot in
        spot.component.items = items
      }
    }
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) { }

  static func generateItem(index: Int, kind: String = "feed") -> ListItem {
    let sencenceCount = Int(arc4random_uniform(4) + 2)

    let item = ListItem(title: faker.lorem.sentences(amount: sencenceCount),
      subtitle: faker.lorem.sentences(amount: 1),
      kind: kind,
      image: faker.internet.image(width: 180, height: 180) + "?type=avatar&id=\(index)")

    return item
  }

  static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ListItem] {
    var items = [ListItem]()
    for i in from...from+to {
      autoreleasepool({
        items.append(generateItem(i))
      })
    }
    return items
  }
}

extension ForYouController: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    let items = ForYouController.generateItems(spot.component.items.count, to: 10)
    delay(0.5) {
      self.prepend(items)
      completion?()
    }
  }
}

extension ForYouController: SpotsScrollDelegate {

  func spotDidReachEnd(completion: (() -> Void)?) {
    if spot.component.items.count < 100 {
      let items = ForYouController.generateItems(spot.component.items.count, to: 10)
      append(items)
    }
    delay(0.3) { completion?() }
  }
}
