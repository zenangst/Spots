import Spots
import Sugar
import Fakery

class ForYouController: SpotsController, SpotsDelegate {

  static let faker = Faker()

  convenience init(title: String) {
    let component = Component()
    let feedSpot = FeedSpot(component: component)
    self.init(spots: [feedSpot], refreshable: false)
    
    self.title = title
    spotDelegate = self
    collectionView.scrollEnabled = false

    dispatch(queue: .Interactive) { [weak self] in
      let items = ForYouController.generateItems(0, to: 10)
      self?.updateSpotAtIndex(0, closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }
  }

  func spotsDidReload(refreshControl: UIRefreshControl) {
    if let spot = spotAtIndex(0) {
      let items = ForYouController.generateItems(spot.component.items.count, to: 10)
      prepend(items)
      delay(0.5) {
        refreshControl.endRefreshing()
      }
    }
  }

  func spotDidReachEnd(completion: (() -> Void)?) {
    if let spot = spotAtIndex(0) {
      if spot.component.items.count < 100 {
        let items = ForYouController.generateItems(spot.component.items.count, to: 10)
        append(items)
      }
      delay(0.3) { completion?() }
    }
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) { }

  static func generateItem(index: Int, kind: String = "feed") -> ListItem {
    let sencenceCount = Int(arc4random_uniform(4) + 2)

    let item = ListItem(title: faker.lorem.sentences(amount: sencenceCount),
      subtitle: faker.lorem.sentences(amount: 1),
      kind: kind,
      image: "http://lorempixel.com/180/180?type=avatar&id=\(index)")

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
