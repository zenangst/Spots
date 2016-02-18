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
  }

  func spotDidSelectItem(spot: Spotable, item: ViewModel) { }

  static func generateItem(index: Int, kind: String = "feed") -> ViewModel {
    let sencenceCount = Int(arc4random_uniform(4) + 2)

    let item = ViewModel(title: faker.lorem.sentences(amount: sencenceCount),
      subtitle: faker.lorem.sentences(amount: 1),
      kind: kind,
      image: faker.internet.image(width: 180, height: 180) + "?type=avatar&id=\(index)")

    return item
  }

  static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ViewModel] {
    var items = [ViewModel]()
    for i in from...from+to {
      autoreleasepool({
        items.append(generateItem(i))
      })
    }
    return items
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dispatch(queue: .Interactive) { [weak self] in
      let items = ForYouController.generateItems(0, to: 10)
      self?.update { spot in
        spot.component.items = items
      }
    }
  }
}

extension ForYouController: SpotsScrollDelegate {

  func spotDidReachBeginning(completion: (() -> Void)?) {
    guard spot.component.items.count < 100 &&
      view.window != nil
      else {
        completion?()
        return
    }

    guard let navigationBar = navigationController?.navigationBar,
      topItem = navigationBar.topItem else { return }

    let items = ForYouController.generateItems(self.spot.component.items.count, to: 10)

    let animation = CATransition()
    animation.duration = 0.3
    animation.type = kCATransitionFade
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)

    navigationBar.layer.addAnimation(animation, forKey: "Animate Title")

    let previousTitle = topItem.title ?? ""
    topItem.title = "Checking for stories..."
    delay(1.0) {
      self.spot.items.insertContentsOf(items, at: 0)
      self.spot.prepare()

      let height = self.spot.items[0..<items.count].reduce(0, combine: { $0 + $1.size.height })

      self.spot(0, ListSpot.self)?.tableView.insert(Array(0..<(items.count)), section: 0, animation: .None)
      self.spot(0, ListSpot.self)?.tableView.reload(Array((items.count)..<(items.count)), section: 0, animation: .None)

      self.spotsScrollView.contentOffset.y = height - self.spotsScrollView.contentInset.top

      navigationBar.layer.addAnimation(animation, forKey: "Animate Title")
      topItem.title = previousTitle
      completion?()
    }
  }

  func spotDidReachEnd(completion: (() -> Void)?) {
    if spot.component.items.count < 100 {
      let items = ForYouController.generateItems(spot.component.items.count, to: 10)
      append(items)
    }
    delay(0.3) { completion?() }
  }
}
