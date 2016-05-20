import UIKit
import Sugar
import Brick
import Cache

/**
 SpotsController is a subclass of UIViewController
 */
public class SpotsController: UIViewController, SpotsProtocol, UIScrollViewDelegate {

  /// A static closure to configure SpotsScrollView
  public static var configure: ((container: SpotsScrollView) -> Void)?

  /// Initial content offset for SpotsController, defaults to UIEdgeInsetsZero
  public private(set) var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero
  /// A collection of Spotable objects
  public var spots: [Spotable] {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the SpotsController is refeshing
  public var refreshing = false
  public var stateCache: SpotCache?

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A convenience method for resolving the first spot
  public var spot: Spotable? {
    get { return spot(0, Spotable.self) }
  }

#if os(iOS)
  /// A refresh delegate for handling reloading of a Spot
  weak public var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      refreshControl.hidden = spotsRefreshDelegate == nil
    }
  }
#endif

  /// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then { [weak self] in
    guard let strongSelf = self else { return }

    $0.frame = strongSelf.view.frame
    $0.alwaysBounceVertical = true
    $0.clipsToBounds = true
    $0.delegate = strongSelf
  }

#if os(iOS)
  /// A UIRefresh control
  /// Note: Only avaiable on iOS
  public lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshSpots(_:)), forControlEvents: .ValueChanged)

    return refreshControl
  }()
#endif

  // MARK: Initializer

  /**
   - Parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
  }

  /**
   - Parameter spot: A Spotable object
   */
  public convenience init(spot: Spotable)  {
    self.init(spots: [spot])
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   */
  public convenience init(_ json: [String : AnyObject]) {
    self.init(spots: Parser.parse(json))
  }

  /**
   - Parameter cacheKey: A key that will be used to identify the SpotCache
   */
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    spotsScrollView.delegate = nil
  }

  // MARK: - View Life Cycle

  /// Called after the spot controller's view is loaded into memory.
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)

    setupSpots()

    SpotsController.configure?(container: spotsScrollView)
  }

  /// Notifies the spot controller that its view is about to be added to a view hierarchy.
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    spotsScrollView.forceUpdate = true

    if let tabBarController = self.tabBarController
      where tabBarController.tabBar.translucent {
        spotsScrollView.contentInset.bottom = tabBarController.tabBar.height
        spotsScrollView.scrollIndicatorInsets.bottom = spotsScrollView.contentInset.bottom
    }
#if os(iOS)
    guard let _ = spotsRefreshDelegate where refreshControl.superview == nil
      else { return }

    spotsScrollView.insertSubview(refreshControl, atIndex: 0)
#endif
  }

  /// Notifies the container that the size of tis view is about to change.
  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
  */
  public func setupSpots(animated: ((view: UIView) -> Void)? = nil) {
    spots.enumerate().forEach { index, spot in
      spots[index].index = index
      spot.render().optimize()
      spotsScrollView.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(spotsScrollView.frame.size)
      spot.component.size = CGSize(
        width: view.width,
        height: ceil(spot.render().height))
      animated?(view: spot.render())
    }
  }

  /**
   Clear Spots cache
   */
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                    NSSearchPathDomainMask.UserDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(SpotCache.cacheName)"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) }
    catch { NSLog("Could not remove cache at path: \(path)") }
  }
}

// MARK: - Public SpotController methods

extension SpotsController {

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reloadIfNeeded(json: [String : AnyObject], animated: ((view: UIView) -> Void)? = nil, closure: Completion = nil) {
    let newSpots = Parser.parse(json)
    let newComponents = newSpots.map { $0.component }
    let oldComponents = spots.map { $0.component }

    guard oldComponents != newComponents else {
      cache()
      closure?()
      return
    }

    spots = newSpots
    cache()

    if spotsScrollView.superview == nil {
      view.addSubview(spotsScrollView)
    }

    spotsScrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    setupSpots(animated)
    spotsScrollView.forceUpdate = true

    closure?()
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(json: [String : AnyObject], animated: ((view: UIView) -> Void)? = nil, closure: Completion = nil) {
    spots = Parser.parse(json)
    cache()

    if spotsScrollView.superview == nil {
      view.addSubview(spotsScrollView)
    }

    spotsScrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    setupSpots(animated)
    spotsScrollView.forceUpdate = true
    
    closure?()
  }

  #if os(iOS)
  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif
}

// MARK: - Private methods

/// An extension with private methods on SpotsController
extension SpotsController {

  /**
   - Parameter indexPath: The index path of the component you want to lookup
   */
  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - Parameter indexPath: The index path of the spot you want to lookup
   */
  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
