import Spots
import Sugar
import Fakery
import Brick
import Transition

class ForYouController: SpotsController, SpotsDelegate {

  static let faker = Faker()

  weak var selectedCell: UITableViewCell?
  weak var detailNavigation: UINavigationController?

  lazy var featuredImage = UIImageView(frame: CGRect.zero).then {
    $0.contentMode = .ScaleAspectFill
    $0.clipsToBounds = true
  }

  lazy var transition: Transition = { [unowned self] in
    let transition = Transition() { [weak self] controller, show in

      if controller.isBeingPresented() {
        guard let weakSelf = self,
          cell = self?.selectedCell else { return }

        controller.view.alpha = 0

        if let imageView = cell.accessoryView as? UIImageView {
          weakSelf.featuredImage.image = imageView.image
          weakSelf.featuredImage.frame = cell.convertRect(weakSelf.view.bounds, toView: weakSelf.view)
          weakSelf.featuredImage.frame.size = CGSize(width: 100, height: 100)
          weakSelf.featuredImage.x = cell.frame.width - weakSelf.featuredImage.frame.width - 15
          weakSelf.featuredImage.y += 15
        }

        if let featuredCell = cell as? FeaturedFeedItemCell {
          weakSelf.featuredImage.image = featuredCell.featuredImage.image
          weakSelf.featuredImage.frame = cell.convertRect(weakSelf.view.bounds, toView: weakSelf.view)
          weakSelf.featuredImage.frame.size = CGSize(width: cell.frame.width - 30, height: 200)
          weakSelf.featuredImage.x = 15
          weakSelf.featuredImage.y += 15
        }

        cell.accessoryView?.alpha = 0.0
        weakSelf.view.addSubview(weakSelf.featuredImage)

        UIView.animateWithDuration(0.20, delay: 0.0, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: {
          weakSelf.featuredImage.frame = CGRect(x: 0, y: 64, width: cell.frame.width, height: 300)

          UIView.animateWithDuration(0.4, delay: 0.10, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: {
            weakSelf.spot.render().transform = CGAffineTransformMakeScale(2.0,2.0)
            weakSelf.spot.render().alpha = 0.0
            controller.view.alpha = 1
            }) { _ in
              cell.accessoryView?.alpha = 1.0
              weakSelf.featuredImage.image = nil
              weakSelf.featuredImage.removeFromSuperview()
          }

          }) { _ in }



        weakSelf.selectedCell = nil
      } else if !show && controller.isBeingDismissed() {
        self?.spot.render().transform = CGAffineTransformIdentity
        self?.spot.render().alpha = 1.0
        controller.view.alpha = 0.0
      }
    }

    transition.animationDuration = 0.4

    return transition
  }()

  convenience init(title: String) {
    self.init(spot: ListSpot(component: Component()))
    self.title = title
  }

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    var item = item
    item.update(kind: Cell.FeedDetail)
    item.subtitle = ForYouController.faker.lorem.sentences(amount: 20)

    if let cell = self.spot(0, ListSpot.self)?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: item.index, inSection: 0)) {
      selectedCell = cell
    }

    let controller = ForYouDetailController(spot: ListSpot(component: Component(items: [
      item,
      ViewModel(title: ForYouController.faker.lorem.sentences(amount: 1),
        subtitle: ForYouController.faker.lorem.sentences(amount: 40),
        kind: Cell.FeedDetail)
    ])))
    controller.spotsScrollView.contentInset.top = 64
    controller.viewDidLoad()
    let navigationController = UINavigationController(rootViewController: controller)
    navigationController.transitioningDelegate = transition
    navigationController.modalPresentationStyle = .Custom
    navigationController.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: controller, action: #selector(ForYouDetailController.detailDidDismiss(_:)))

    self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)

    detailNavigation = navigationController
  }

  static func generateItem(index: Int, kind: Cell = Cell.Feed) -> ViewModel {
    let sentences = Int(arc4random_uniform(2) + 2)

    let item = ViewModel(title: faker.lorem.sentences(amount: sentences),
      subtitle: faker.lorem.sentences(amount: 2),
      kind: kind,
      image: faker.internet.image(width: 180, height: 180) + "?type=avatar&id=\(index)")

    return item
  }

  static func generateItems(from: Int, to: Int, kind: Cell = Cell.Feed) -> [ViewModel] {
    var items = [ViewModel]()
    for i in from...from+to {
      let kind = Int(arc4random_uniform(100)) % 10 == 1
        ? Cell.FeaturedFeed
        : Cell.Feed

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
