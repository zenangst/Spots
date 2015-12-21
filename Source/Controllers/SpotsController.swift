import UIKit
import Sugar

public typealias SpotController = SpotsController

public class SpotsController: UIViewController, UIScrollViewDelegate {

  public static var configure: ((container: SpotsScrollView) -> Void)?

  public private(set) var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero
  public private(set) var spots: [Spotable]

  public var refreshing = false {
    didSet { if !refreshing { refreshControl.endRefreshing() } }
  }

  weak public var spotsDelegate: SpotsDelegate? {
    didSet { spots.forEach { $0.spotsDelegate = spotsDelegate } }
  }

  var spot: Spotable {
    get {
      return spot(0)!
    }
  }

  weak public var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      if spotsRefreshDelegate != nil {
        tableView.addSubview(refreshControl)
        container.addSubview(tableView)
      } else {
        [refreshControl, tableView].forEach { $0.removeFromSuperview() }
      }
    }
  }

  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  lazy public var container: SpotsScrollView = { [unowned self] in
    let container = SpotsScrollView(frame: self.view.frame)
    container.alwaysBounceVertical = true
    container.backgroundColor = UIColor.whiteColor()
    container.clipsToBounds = true
    container.delegate = self

    return container
    }()

  public lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView(frame: CGRect(x: 0, y: -60, width: UIScreen.mainScreen().bounds.width, height: 60))
    tableView.userInteractionEnabled = false
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.backgroundColor = UIColor.clearColor()

    return tableView
    }()

  public lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshSpot:", forControlEvents: .ValueChanged)

    return refreshControl
    }()

  // MARK: Initializer

  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    view.addSubview(container)

    spots.enumerate().forEach { spot($0.index).index = $0.index }
  }

  public convenience init(spot: Spotable)  {
    self.init(spots: [spot])
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //MARK: - View Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    spots.forEach { spot in
      spot.render().optimize()
      container.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(container.frame.size)
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
    }
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if !container.configured {
      configureContainer()
    }
  }

  public override func viewDidAppear(animated: Bool) {
    container.configured = true
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  private func configureContainer() {
    container.frame = UIScreen.mainScreen().bounds
    container.frame.size.height -= ceil(container.contentInset.top + container.contentOffset.y)
    container.contentInset.bottom = tabBarController?.tabBar.frame.height ?? container.contentInset.bottom

    SpotsController.configure?(container: container)

    initialContentInset = container.contentInset

    spots.forEach { spot in
      spot.render().layoutSubviews()
      spot.render().setNeedsDisplay()
    }
  }
}

// MARK: - Public SpotController methods

extension SpotsController {

  public func spot(index: Int = 0) -> Spotable? {
    return spots.filter{ $0.index == index }.first
  }

  public func spot(closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerate()
      where closure(index: index, spot: spot) {
        return spot
    }
    return nil
  }

  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  public func reload() {
    dispatch { [weak self] in
      self?.spots.forEach { $0.reload([]) {} }
    }
  }

  public func update(index: Int = 0, closure: (spot: Spotable) -> Spotable, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(index) else { return }
    spots[spot.index] = closure(spot: spot)
    spot.prepare()
    spot.setup(container.bounds.size)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index).reload([index]) { }
    }
  }

  public func append(item: ListItem, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(item) { completion?() }
  }

  public func append(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(items) { completion?() }
  }

  public func prepend(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.prepend(items)  { completion?() }
  }

  public func insert(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.insert(item, index: index)  { completion?() }
  }

  public func update(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.update(item, index: index)  { completion?() }
  }

  public func delete(index: Int, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(index) { completion?() }
  }

  public func delete(indexes indexes: [Int], spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(indexes) { completion?() }
  }

  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      if let weakSelf = self {
        weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) { }
      }
    }
  }
}

// MARK: - Private methods

extension SpotsController {

  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }

  private func spot(index: Int) -> Spotable {
    return spots[index]
  }
}
