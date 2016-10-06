import UIKit
import Brick
import Cache

/**
 Controller is a subclass of UIViewController
 */
open class Controller: UIViewController, SpotsProtocol, CompositeDelegate, UIScrollViewDelegate {

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
  open static var configure: ((_ container: SpotsScrollView) -> Void)?

  /// Initial content offset for Controller, defaults to UIEdgeInsetsZero
  open fileprivate(set) var initialContentInset: UIEdgeInsets = UIEdgeInsets.zero

  /// A collection of Spotable objects
  open var spots: [Spotable] {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.spotsDidChange(spots)
    }
  }

  /// A collection of composite Spotable objects
  open var compositeSpots: [Int : [Int : [Spotable]]] {
    didSet {
      for (_, items) in compositeSpots {
        for (_, container) in items.enumerated() {
          container.1.forEach { $0.delegate = delegate }
        }
      }
    }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  open var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the Controller is refeshing
  open var refreshing = false
  /// A convenience method for resolving the first spot
  open var spot: Spotable? {
    get { return spot(at: 0, Spotable.self) }
  }

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject!
  #endif

  /// An optional SpotCache used for view controller caching
  open var stateCache: SpotCache?

  /// A delegate for when an item is tapped within a Spot
  weak open var delegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.spotsDidChange(spots)
    }
  }

#if os(iOS)
  /// A refresh delegate for handling reloading of a Spot
  weak open var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      refreshControl.isHidden = spotsRefreshDelegate == nil
    }
  }
#endif

  /// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
  weak open var scrollDelegate: SpotsScrollDelegate?

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy open var scrollView: SpotsScrollView = {  [unowned self] in
    let scrollView = SpotsScrollView()
    scrollView.alwaysBounceVertical = true
    scrollView.clipsToBounds = true
    scrollView.delegate = self

    return scrollView
  }()

#if os(iOS)
  /// A UIRefresh control
  /// Note: Only avaiable on iOS
  open lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshSpots(_:)), for: .valueChanged)

    return refreshControl
  }()
#endif

  // MARK: Initializer

  /**
   - parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    self.compositeSpots = [:]
    super.init(nibName: nil, bundle: nil)

    NotificationCenter.default.addObserver(self, selector:#selector(self.deviceDidRotate(_:)), name: NSNotification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue), object: nil)
  }

  /**
   - parameter spot: A Spotable object
   */
  public convenience init(spot: Spotable) {
    self.init(spots: [spot])
  }

  /**
   - parameter json: A JSON dictionary that gets parsed into UI elements
   */
  public convenience init(_ json: [String : Any]) {
    self.init(spots: Parser.parse(json))
  }

  /**
   - parameter cacheKey: A key that will be used to identify the SpotCache
   */
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
  }

  /**
   Init with coder

   - parameter aDecoder: An NSCoder
   */
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    #if DEVMODE
    if let source = source {
      source.cancel()
    }
    NotificationCenter.default.removeObserver(self)
    #endif
  }

  /***
   A generic look up method for resolving spots based on index
   - parameter index: The index of the spot that you are trying to resolve
   - parameter type: The generic type for the spot you are trying to resolve

   - returns: An optional Spotable object
   */
  open func spot<T>(at index: Int = 0, _ type: T.Type) -> T? {
    return spots.filter({ $0.index == index }).first as? T
  }

  open func spot(at index: Int = 0) -> Spotable? {
    return spots.filter({ $0.index == index }).first
  }

  /**
   A generic look up method for resolving spots using a closure

   - parameter closure: A closure to perform actions on a spotable object
   - returns: An optional Spotable object
   */
  open func resolve(spot closure: (_ index: Int, _ spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerated()
      where closure(index, spot) {
        return spot
    }
    return nil
  }

  // MARK: - Notifications

  /**
   Handle rotation for views that are not on screen

   - parameter notification: A notification containing the new size
   */
  func deviceDidRotate(_ notification: Notification) {
    if let userInfo = (notification as NSNotification).userInfo as? [String : Any],
      let rotationSize = userInfo["size"] as? RotationSize, view.window == nil {
      configureView(withSize: rotationSize.size)
    }
  }

  // MARK: - View Life Cycle

  /// Called after the spot controller's view is loaded into memory.
  open override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(scrollView)
    scrollView.frame = view.bounds

    setupSpots()

    Controller.configure?(scrollView)
  }

  /**
   Notifies the spot controller that its view is about to be added to a view hierarchy.

   - parameter animated: If true, the view is being added to the window using an animation.
   */
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let tabBarController = self.tabBarController, tabBarController.tabBar.isTranslucent {
        scrollView.contentInset.bottom = tabBarController.tabBar.frame.size.height
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
    }
#if os(iOS)
    guard let _ = spotsRefreshDelegate, refreshControl.superview == nil
      else { return }

    scrollView.insertSubview(refreshControl, at: 0)
#endif
  }

  func configureView(withSize size: CGSize) {
    scrollView.frame.size = size
    scrollView.contentView.frame.size = size
    spots.enumerated().forEach { index, spot in
      compositeSpots[index]?.forEach { cIndex, cSpots in
        cSpots.forEach {
          $0.layout(size)
        }
      }
      spot.layout(size)
    }
  }

  /**
   Notifies the container that the size of tis view is about to change.

   - parameter size:        The new size for the container’s view.
   - parameter coordinator: The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.
   */
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    #if os(iOS)
      guard spots_shouldAutorotate() else { return }
    #endif

    coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.configureView(withSize: size)
      }) { (UIViewControllerTransitionCoordinatorContext) in
        self.configureView(withSize: size)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue),
                                                                  object: nil,
                                                                  userInfo: ["size" : RotationSize(size: size)])
    }
  }

  /**
   - parameter animated: An optional animation closure that runs when a spot is being rendered
  */
  open func setupSpots(_ animated: ((_ view: UIView) -> Void)? = nil) {
    var yOffset: CGFloat = 0.0
    compositeSpots = [:]
    spots.enumerated().forEach { index, spot in
      setupSpot(at: index, spot: spot)
      scrollView.contentView.addSubview(spot.render())
      animated?(spot.render())
      (spot as? Gridable)?.layout.yOffset = yOffset
      yOffset += spot.render().frame.size.height
    }
  }

  open func setupSpot(at index: Int, spot: Spotable) {
    spot.render().bounds.size.width = view.bounds.width
    spot.render().frame.origin.x = 0.0
    spot.spotsCompositeDelegate = self
    spots[index].component.index = index
    spot.registerAndPrepare()
    spot.setup(scrollView.frame.size)
    spot.component.size = CGSize(
      width: view.frame.size.width,
      height: ceil(spot.render().frame.size.height))
  }

  #if os(iOS)
  /**
   Refresh action for UIRefreshControl

   - parameter refreshControl:
   */
  open func refreshSpots(_ refreshControl: UIRefreshControl) {
    Dispatch.mainQueue { [weak self] in
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

/// An extension with private methods on Controller
extension Controller {

  /**
   - parameter indexPath: The index path of the component you want to lookup
   - returns: A Component object at index path
   **/
  fileprivate func component(at indexPath: IndexPath) -> Component {
    return spot(at: indexPath).component
  }

  /**
   - parameter indexPath: The index path of the spot you want to lookup
   - returns: A Spotable object at index path
   **/
  fileprivate func spot(at indexPath: IndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
