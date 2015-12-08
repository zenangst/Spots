import UIKit
import Sugar

public class SpotsController: UIViewController, UIScrollViewDelegate {

  public static var configure: ((container: SpotScrollView) -> Void)?

  public private(set) var spots: [Spotable]
  private var refreshing = false {
    didSet {
      if !refreshing {
        refreshControl.endRefreshing()
      }
    }
  }
  private var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero

  lazy public var container: SpotScrollView = { [unowned self] in
    let container = SpotScrollView(frame: self.view.frame)
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

  weak public var spotDelegate: SpotsDelegate?

  public required init(spots: [Spotable] = [], refreshable: Bool = false) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    view.addSubview(container)

    if refreshable {
      tableView.addSubview(refreshControl)
      container.addSubview(tableView)
    }

    spots.enumerate().forEach { spot($0.index).index = $0.index }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    for spot in spots {
      spot.render().optimize()
      container.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(container.frame.size)
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
      spot.spotDelegate = spotDelegate
    }
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

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

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let bounds = scrollView.bounds
    let inset = scrollView.contentInset
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let shouldFetch = offset.y + bounds.size.height - inset.bottom > size.height
      && size.height > bounds.size.height
      && !refreshing

    // Refreshable
    tableView.contentOffset.y = scrollView.contentOffset.y + tableView.frame.height

    if refreshControl.superview != nil && scrollView.contentOffset.y < tableView.frame.origin.y * 2 && !refreshControl.refreshing {
      refreshControl.beginRefreshing()
    }

    // Infinite scrolling
    if shouldFetch && !refreshing {
      refreshing = false
      delay(0.2) {
        self.spotDelegate?.spotDidReachEnd {
          self.refreshing = false
        }
      }
    }
  }

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.refreshing else { return }
    container.contentInset.top = -scrollView.contentOffset.y

    self.spotDelegate?.spotsDidReload(refreshControl) { [weak self] in
      guard let weakSelf = self else { return }
      UIView.animateWithDuration(0.3, animations: {
        weakSelf.container.contentInset = weakSelf.initialContentInset
        }, completion: { _ in
          weakSelf.refreshing = false
      })
    }
  }

  public func spotAtIndex(index: Int) -> Spotable? {
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

  public func reloadSpots() {
    dispatch { [weak self] in
      self?.spots.forEach { $0.reload([]) {} }
    }
  }

  public func updateSpotAtIndex(index: Int, closure: (spot: Spotable) -> Spotable, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(index) else { return }
    spots[spot.index] = closure(spot: spot)

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
      if let weakSelf = self, spotDelegate = weakSelf.spotDelegate {
        spotDelegate.spotsDidReload(refreshControl) { }
      }
    }
  }
}

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
