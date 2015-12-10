import Sugar
import Fakery
import Spots

public class FeedController: SpotsController, SpotsDelegate {

  public static let faker = Faker()
  
  public override func viewDidLoad() {
    self.spotsDelegate = self
    self.spotsScrollDelegate = self
    self.spotsRefreshDelegate = self
    super.viewDidLoad()
  }

  public func spotDidSelectItem(spot: Spotable, item: ListItem) { }

  public static func generateItem(index: Int, kind: String = "feed") -> ListItem {
    let sencenceCount = Int(arc4random_uniform(8) + 1)
    let subtitle = faker.lorem.sentences(amount: sencenceCount) + " " + faker.internet.url()

    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    let item = ListItem(title: faker.name.name(),
      subtitle: subtitle,
      kind: kind,
      image: "http://lorempixel.com/75/75?type=avatar&id=\(index)",
      meta: ["media" : mediaStrings])

    return item
  }

  public static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ListItem] {
    var items = [ListItem]()
    for i in from...from+to {
      autoreleasepool({
        items.append(generateItem(i))
      })
    }
    return items
  }
}

extension FeedController: SpotsRefreshDelegate {

  public func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    delay(1.0) {
      dispatch(queue: .Interactive) { [weak self] in
        guard let spot = self?.spotAtIndex(0) else { return }

        let items = FeedController.generateItems(spot.component.items.count, to: 10)

        self?.prepend(items, spotIndex: 0) {
          dispatch {
            refreshControl.endRefreshing()
            completion?()
          }
        }
      }
    }
  }
}

extension FeedController: SpotsScrollDelegate {

  public func spotDidReachEnd(completion: (() -> Void)?) {
    dispatch(queue: .Interactive) { [weak self] in
      guard let weakSelf = self else { return }
      guard let spot = weakSelf.spotAtIndex(0) else { return }
      let items = FeedController.generateItems(spot.component.items.count, to: 3)
      weakSelf.append(items) { completion?() }
    }
  }
}
