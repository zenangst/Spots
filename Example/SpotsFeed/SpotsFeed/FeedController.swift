import Sugar
import Fakery

public class FeedController: SpotsController, SpotsDelegate {

  public required init(spots: [Spotable], refreshable: Bool) {
    super.init(spots: spots)
    spotDelegate = self
  }

  public required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  public func spotsDidReload(refreshControl: UIRefreshControl) {
    delay(0.5) {
      refreshControl.endRefreshing()

      if let controller = self.navigationController?.visibleViewController as? SpotsController {
        controller.updateSpotAtIndex(0, closure: { (spot: Spotable) -> Spotable in
          spot.component.items.insert(FeedController.generateItem(2), atIndex: 0)
          return spot
        })
      }
    }
  }

  public func spotDidSelectItem(spot: Spotable, item: ListItem) { }

  public func spotDidReachEnd(completion: (() -> Void)?) {
    append(FeedController.generateItems(0, to: 10), spotIndex: 0) {
      completion?()
    }
  }

  public static func generateItem(index: Int, kind: String = "feed") -> ListItem {
    let sencenceCount = Int(arc4random_uniform(8) + 1)
    let subtitle = Faker().lorem.sentences(amount: sencenceCount) + " " + Faker().internet.url()

    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    return ListItem(title: Faker().name.name(),
      subtitle: subtitle,
      kind: kind,
      image: "http://lorempixel.com/75/75?type=avatar&id=\(index)",
      meta: ["media" : mediaStrings])
  }

  public static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ListItem] {
    var items = [ListItem]()
    for i in from...to {
      autoreleasepool({
        items.append(generateItem(i))
      })
    }
    return items
  }
}
