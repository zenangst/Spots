import UIKit
import Sugar

public class SpotsController: UIViewController, UIScrollViewDelegate {

  public static var configure: ((container: SpotsScrollView) -> Void)?

  public private(set) var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero
  public private(set) var spots: [Spotable]

  public var refreshPositions = [CGFloat]()

  public var refreshing = false {
    didSet { if !refreshing { refreshControl.endRefreshing() } }
  }

  weak public var spotsDelegate: SpotsDelegate? {
    didSet { spots.forEach { $0.spotsDelegate = spotsDelegate } }
  }

  public var spot: Spotable {
    get { return spot(0)! }
  }

  weak public var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      if spotsRefreshDelegate != nil {
        tableView.addSubview(refreshControl)
        spotsScrollView.addSubview(tableView)
      } else {
        [refreshControl, tableView].forEach { $0.removeFromSuperview() }
      }
    }
  }

  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then { [unowned self] in
    $0.frame = self.view.frame
    $0.alwaysBounceVertical = true
    $0.backgroundColor = UIColor.whiteColor()
    $0.clipsToBounds = true
    $0.delegate = self
  }


  public lazy var tableView = UITableView().then {
    $0.frame = CGRect(x: 0, y: -60, width: UIScreen.mainScreen().bounds.width, height: 60)
    $0.userInteractionEnabled = false
    $0.tableFooterView = UIView(frame: CGRect.zero)
    $0.backgroundColor = UIColor.clearColor()
  }

  public lazy var refreshControl: UIRefreshControl = UIRefreshControl().then { [unowned self] in
    $0.addTarget(self, action: "refreshSpot:", forControlEvents: .ValueChanged)
  }

  // MARK: Initializer

  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    view.addSubview(spotsScrollView)
    spots.enumerate().forEach { spots[$0.index].index = $0.index }
  }

  public convenience init(spot: Spotable)  {
    self.init(spots: [spot])
  }

  public convenience init(_ json: [String : AnyObject]) {
    self.init(spots: Parser.parse(json))
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //MARK: - View Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    spots.forEach { spot in
      spot.render().optimize()
      spotsScrollView.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(spotsScrollView.frame.size)
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
    }
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if !spotsScrollView.configured {
      configureContainer()
    }
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    spotsScrollView.configured = true
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  private func configureContainer() {
    spotsScrollView.frame = UIScreen.mainScreen().bounds
    spotsScrollView.frame.size.height -= ceil(spotsScrollView.contentInset.top + spotsScrollView.contentOffset.y)
    spotsScrollView.contentInset.bottom = tabBarController?.tabBar.frame.height ?? spotsScrollView.contentInset.bottom

    SpotsController.configure?(container: spotsScrollView)

    initialContentInset = spotsScrollView.contentInset

    spots.forEach {
      $0.render().layoutSubviews()
      $0.render().setNeedsDisplay()
    }
  }
}

// MARK: - Public SpotController methods

extension SpotsController {

  public func spot(index: Int = 0) -> Spotable? {
    return spots.filter{ $0.index == index }.first
  }

  public func spot(@noescape closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
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

  public func update(spotAtIndex index: Int = 0, @noescape _ closure: (spot: Spotable) -> Void) {
    guard let spot = spot(index) else { return }
    closure(spot: spot)
    spot.prepare()
    spot.setup(spotsScrollView.bounds.size)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index)?.reload([index]) {
        weakSelf.spotsScrollView.setNeedsDisplay()
        weakSelf.spotsScrollView.forceUpdate = true
      }
    }
  }

  public func append(item: ListItem, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.append(item) { completion?() }
  }

  public func append(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.append(items) { completion?() }
  }

  public func prepend(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.prepend(items)  { completion?() }
  }

  public func insert(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.insert(item, index: index)  { completion?() }
  }

  public func update(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.update(item, index: index)  { completion?() }
  }

  public func delete(index: Int, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.delete(index) { completion?() }
  }

  public func delete(indexes indexes: [Int], spotIndex: Int, completion: (() -> Void)? = nil) {
    spot(spotIndex)?.delete(indexes) { completion?() }
  }

  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) { }
    }
  }

  public func scrollToItem(@noescape includeElement: (ListItem) -> Bool, spotIndex index: Int) {
    guard let itemY = spot(index)?.scrollTo(includeElement) else { return }

    if spot(index)?.spotHeight() > spotsScrollView.frame.height - spotsScrollView.contentInset.bottom {
      let y = itemY - spotsScrollView.frame.height + spotsScrollView.contentInset.bottom
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
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
}
