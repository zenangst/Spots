import UIKit
import Sugar
import Brick
import Cache

/**
 SpotsController is a subclass of UIViewController
 */
public class SpotsController: UIViewController, SpotsProtocol, SpotsCompositeDelegate, UIScrollViewDelegate {

  /**
   A notification enum

   - deviceDidRotateNotification: Used when the device is rotated
   */
  enum NotificationKeys: String {
    case deviceDidRotateNotification = "deviceDidRotateNotification"
  }

  /// A rotation class that is used in the `deviceDidRotate` notification
  class RotationSize {
    let size: CGSize

    init(size: CGSize) {
      self.size = size
    }
  }

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

  public var compositeSpots: [Int : [Spotable]] {
    didSet {
      for (index, elements) in compositeSpots {
        elements.forEach { $0.spotsDelegate = spotsDelegate }
      }
    }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the SpotsController is refeshing
  public var refreshing = false
  /// A convenience method for resolving the first spot
  public var spot: Spotable? {
    get { return spot(0, Spotable.self) }
  }

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: dispatch_source_t!
  #endif

  /// An optional SpotCache used for view controller caching
  public var stateCache: SpotCache?

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
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
    self.compositeSpots = [:]
    super.init(nibName: nil, bundle: nil)

    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.deviceDidRotate(_:)), name: NotificationKeys.deviceDidRotateNotification.rawValue, object: nil)
  }

  /**
   - Parameter spot: A Spotable object
   */
  public convenience init(spot: Spotable) {
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

  /**
   Init with coder

   - Parameter aDecoder: An NSCoder
   */
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    #if DEVMODE
    if let source = source {
      dispatch_source_cancel(source)
    }
    NSNotificationCenter.defaultCenter().removeObserver(self)
    #endif
  }

  /**
   A generic look up method for resolving spots based on index
   - Parameter index: The index of the spot that you are trying to resolve
   - Parameter type: The generic type for the spot you are trying to resolve
   */
  public func spot<T>(index: Int = 0, _ type: T.Type) -> T? {
    return spots.filter({ $0.index == index }).first as? T
  }

  /**
   A generic look up method for resolving spots using a closure
   - Parameter closure: A closure to perform actions on a spotable object
   */
  public func spot(@noescape closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerate()
      where closure(index: index, spot: spot) {
        return spot
    }
    return nil
  }

  // MARK: - Notifications

  /**
   Handle rotation for views that are not on screen

   - parameter notification: A notification containing the new size
   */
  func deviceDidRotate(notification: NSNotification) {
    if let userInfo = notification.userInfo as? [String : AnyObject],
      rotationSize = userInfo["size"] as? RotationSize
      where view.window == nil {
      configureView(withSize: rotationSize.size)
    }
  }

  // MARK: - View Life Cycle

  /// Called after the spot controller's view is loaded into memory.
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)
    spotsScrollView.frame = view.bounds

    setupSpots()

    SpotsController.configure?(container: spotsScrollView)
  }

  /**
   Notifies the spot controller that its view is about to be added to a view hierarchy.

   - Parameter animated: If true, the view is being added to the window using an animation.
   */
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    defer { spotsScrollView.forceUpdate = true }

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

  /**
   Notifies the view controller that its view was added to a view hierarchy.

   - parameter animated: If true, the view was added to the window using an animation.
   */
  override public func viewDidAppear(animated: Bool) {
    spotsScrollView.forceUpdate = true
    super.viewDidAppear(animated)
  }

  func configureView(withSize size: CGSize) {
    spotsScrollView.frame.size = size
    spotsScrollView.contentView.frame.size = size
    spots.enumerate().forEach {
      compositeSpots[$0.index]?.forEach { $0.layout(size) }
      $0.element.layout(size)
    }
  }

  /**
   Notifies the container that the size of tis view is about to change.

   - Parameter size:        The new size for the container’s view.
   - Parameter coordinator: The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.
   */
  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) in
      self.configureView(withSize: size)
      }) { (UIViewControllerTransitionCoordinatorContext) in
        self.configureView(withSize: size)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.deviceDidRotateNotification.rawValue,
                                                                  object: nil,
                                                                  userInfo: ["size" : RotationSize(size: size)])
    }
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
  */
  public func setupSpots(animated: ((view: UIView) -> Void)? = nil) {
    var yOffset: CGFloat = 0.0
    compositeSpots = [:]
    spots.enumerate().forEach { index, spot in
      spot.spotsCompositeDelegate = self
      spots[index].component.index = index
      spot.render().optimize()
      spotsScrollView.contentView.addSubview(spot.render())
      spot.registerAndPrepare()
      spot.setup(spotsScrollView.frame.size)
      spot.component.size = CGSize(
        width: view.width,
        height: ceil(spot.render().height))
      animated?(view: spot.render())

      (spot as? Gridable)?.layout.yOffset = yOffset
      yOffset += spot.render().frame.size.height
    }
  }

  #if os(iOS)
  /**
   Refresh action for UIRefreshControl

   - Parameter refreshControl:
   */
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
   - Returns: A Component object at index path
   **/
  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - Parameter indexPath: The index path of the spot you want to lookup
   - Returns: A Spotable object at index path
   **/
  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
