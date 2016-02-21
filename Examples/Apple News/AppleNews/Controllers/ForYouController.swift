import Spots
import Sugar
import Fakery
import Transition

class ForYouController: SpotsController, SpotsDelegate {

  static let faker = Faker()

  weak var selectedCell: UITableViewCell?

  lazy var transition: Transition = { [unowned self] in
    let transition = Transition() { [weak self] controller, show in
      guard let weakSelf = self,
      cell = self?.selectedCell else { return }

      controller.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
      controller.view.alpha = show ? 1 : 0
      let centerY = controller.view.center.y
      var newY = cell.convertRect(weakSelf.view.bounds, toView: weakSelf.view).origin.y
      controller.view.center.y = newY

      UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
        controller.view.transform = CGAffineTransformIdentity
        controller.view.alpha = 1
        controller.view.center.y = centerY
        }, completion: nil)

      weakSelf.selectedCell = nil
    }

    return transition
  }()

  convenience init(title: String) {
    self.init(spot: ListSpot(component: Component()))
    self.title = title
  }

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    var item = item
    item.kind = "feed-detail"
    item.subtitle = ForYouController.faker.lorem.sentences(amount: 20)

    if let cell = self.spot(0, ListSpot.self)?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: item.index, inSection: 0)) {
      selectedCell = cell
    }

    let controller = ForYouDetailController(spot: ListSpot(component: Component(items: [item])))
    controller.spotsScrollView.contentInset.top = 64
    controller.viewDidLoad()
    let navigationController = UINavigationController(rootViewController: controller)
    navigationController.transitioningDelegate = transition

    self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
  }

  static func generateItem(index: Int, kind: String = "feed") -> ViewModel {
    let sentences = Int(arc4random_uniform(2) + 2)

    let item = ViewModel(title: faker.lorem.sentences(amount: sentences),
      subtitle: faker.lorem.sentences(amount: 2),
      kind: kind,
      image: faker.internet.image(width: 180, height: 180) + "?type=avatar&id=\(index)")

    return item
  }

  static func generateItems(from: Int, to: Int, kind: String = "feed") -> [ViewModel] {
    var items = [ViewModel]()
    for i in from...from+to {
      let kind = Int(arc4random_uniform(100)) % 10 == 1
        ? "featured-feed"
        : "feed"

      autoreleasepool { items.append(generateItem(i, kind: kind)) }
    }
    return items
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    spotsDelegate = self
    spotsScrollDelegate = self

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
    guard spot.component.items.count < 100 && view.window != nil
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
      append(ForYouController.generateItems(spot.component.items.count, to: 10))
    }
    delay(0.3) { completion?() }
  }
}
