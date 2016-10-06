import Sugar
import Fakery
import Spots
import Brick

open class FeedController: Controller, SpotsDelegate {

  open static let faker = Faker()

  open override func viewDidLoad() {
    self.delegate = self
    self.scrollDelegate = self
    self.refreshDelegate = self
    super.viewDidLoad()
  }

  open func spotDidSelectItem(_ spot: Spotable, item: Item) { }

  open static func generateItem(_ index: Int, kind: String = "feed") -> Item {
    let sencenceCount = Int(arc4random_uniform(8) + 1)
    let subtitle = faker.lorem.sentences(amount: sencenceCount) + " " + faker.internet.url()

    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    let item = Item(title: faker.name.name(),
      subtitle: subtitle,
      image: "http://lorempixel.com/75/75?type=avatar&id=\(index)",
      kind: kind,
      meta: ["media" : mediaStrings])

    return item
  }

  open static func generateItems(_ from: Int, to: Int, kind: String = "feed") -> [Item] {
    var items = [Item]()
    for i in from...from+to {
      autoreleasepool(invoking: {
        items.append(generateItem(i))
      })
    }
    return items
  }
}

extension FeedController: RefreshDelegate {

  public func spotsDidReload(_ refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    delay(1.0) {
      dispatch(queue: .interactive) { [weak self] in
        guard let weakSelf = self, let spot = weakSelf.spot else { return }
        let items = FeedController.generateItems(spot.component.items.count, to: 10)

        weakSelf.prepend(items) { completion?() }
      }
    }
  }
}

extension FeedController: SpotsScrollDelegate {

  public func spotDidReachEnd(_ completion: (() -> Void)?) {
    dispatch(queue: .interactive) { [weak self] in
      guard let weakSelf = self, let spot = weakSelf.spot else { return }
      let items = FeedController.generateItems(spot.component.items.count, to: 3)
      dispatch {
        weakSelf.append(items) { completion?() }
      }
    }
  }
}
