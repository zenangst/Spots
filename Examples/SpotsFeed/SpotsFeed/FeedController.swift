import Sugar
import Fakery
import Spots
import Brick

public class FeedController: SpotsController, SpotsDelegate {

  public static let faker = Faker()

  public override func viewDidLoad() {
    self.spotsDelegate = self
    self.spotsScrollDelegate = self
    self.spotsRefreshDelegate = self
    super.viewDidLoad()
  }

  public func spotDidSelectItem(spot: Spotable, item: ViewModel) { }

  public static func generateItem(index: Int, kind: String = "feed") -> ViewModel {
    let sencenceCount = Int(arc4random_uniform(8) + 1)
    let subtitle = faker.lorem.sentences(amount: sencenceCount) + " " + faker.internet.url()

    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    let item = ViewModel(title: faker.name.name(),
      subtitle: subtitle,
      kind: kind,
      image: "http://lorempixel.com/75/75?type=avatar&id=\(index)",
      meta: ["media" : mediaStrings])

    return item
  }

  public static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ViewModel] {
    var items = [ViewModel]()
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
        guard let weakSelf = self else { return }
        let items = FeedController.generateItems(weakSelf.spot.component.items.count, to: 10)

        weakSelf.prepend(items) { completion?() }
      }
    }
  }
}

extension FeedController: SpotsScrollDelegate {

  public func spotDidReachEnd(completion: (() -> Void)?) {
    dispatch(queue: .Interactive) { [weak self] in
      guard let weakSelf = self else { return }
      let items = FeedController.generateItems(weakSelf.spot.component.items.count, to: 3)
      dispatch {
        weakSelf.append(items) { completion?() }
      }
    }
  }
}
