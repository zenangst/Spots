import UIKit
import Brick
import Cache

/// A controller powered by Spotable objects
open class Controller: UIViewController, SpotsProtocol, CompositeDelegate, UIScrollViewDelegate {

  /// A notification enum
  ///
  /// - deviceDidRotateNotification: Used when the device is rotated
  private enum NotificationKeys: String {
    /// A notification key for when the device did rotate
    case deviceDidRotateNotification = "deviceDidRotateNotification"
  }

  /// A rotation class that is used in the `deviceDidRotate` notification
  private class RotationSize {
    /// The new size after rotating.
    let size: CGSize

    /// Initialize a new size when rotating
    ///
    /// - Parameter size: A CGSize with the new size after rotating the device.
    init(size: CGSize) {
      self.size = size
    }
  }

  /// A static closure to configure SpotsScrollView.
  open static var configure: ((_ container: SpotsScrollView) -> Void)?

  /// Initial content offset for Controller, defaults to UIEdgeInsetsZero.
  open fileprivate(set) var initialContentInset: UIEdgeInsets = UIEdgeInsets.zero

  /// A collection of Spotable objects.
  open var spots: [Spotable] {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.didChange(spots: spots)
    }
  }

  /// A collection of composite Spotable objects.
  open var compositeSpots: [Int : [Int : [Spotable]]] {
    didSet {
      for (_, items) in compositeSpots {
        for (_, container) in items.enumerated() {
          container.1.forEach { $0.delegate = delegate }
        }
      }
    }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling.
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the Controller is refeshing.
  public var refreshing = false
  /// A convenience method for resolving the first spot.
  public var spot: Spotable? {
    get { return spot(at: 0, ofType: Spotable.self) }
  }

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject!
  #endif

  /// An optional StateCache used for view controller caching.
  public var stateCache: StateCache?

  /// A delegate for when an item is tapped within a Spot.
  weak open var delegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.didChange(spots: spots)
    }
  }

#if os(iOS)
  /// A refresh delegate for handling reloading of a Spot.
  weak public var refreshDelegate: RefreshDelegate? {
    didSet {
      refreshControl.isHidden = refreshDelegate == nil
    }
  }
#endif

  /// A scroll delegate for handling didReachBeginning and didReachEnd.
  weak public var scrollDelegate: ScrollDelegate?

  /// A custom scroll view that handles the scrolling for all internal scroll views.
  open var scrollView: SpotsScrollView = SpotsScrollView()

#if os(iOS)
  /// A UIRefresh control.
  /// Note: Only available on iOS.
  public lazy var refreshControl = UIRefreshControl()
#endif

  // MARK: Initializer

  /// A required initializer for initializing a controller with Spotable objects
  ///
  /// - parameter spots: A collection of Spotable objects that should be setup and be added to the view hierarchy.
  ///
  /// - returns: An initalized controller.
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    self.compositeSpots = [:]
    super.init(nibName: nil, bundle: nil)

    NotificationCenter.default.addObserver(self, selector:#selector(self.deviceDidRotate(_:)), name: NSNotification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue), object: nil)
  }

  /// Initialize a new controller with a single spot
  ///
  /// - parameter spot: A Spotable object
  ///
  /// - returns: An initialized controller containing one object.
  public convenience init(spot: Spotable) {
    self.init(spots: [spot])
  }

  /// Initialize a new controller using JSON.
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements.
  ///
  /// - returns: An initialized controller with Spotable objects built from JSON.
  public convenience init(_ json: [String : Any]) {
    self.init(spots: Parser.parse(json))
  }

  /// Initialize a new controller with a cache key.
  ///
  /// - parameter cacheKey: A key that will be used to identify the StateCache.
  ///
  /// - returns: An initialized controller with a cache.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
  }

  /// Init with coder.
  ///
  /// - parameter aDecoder: An NSCoder
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

    // http://stackoverflow.com/questions/3686803/uiscrollview-exc-bad-access-crash-in-ios-sdk
    scrollView.delegate = nil
  }

  ///  A generic look up method for resolving spots based on index
  ///
  /// - parameter index: The index of the spot that you are trying to resolve.
  /// - parameter type: The generic type for the spot you are trying to resolve.
  ///
  /// - returns: An optional Spotable object of inferred type.
  open func spot<T>(at index: Int = 0, ofType type: T.Type) -> T? {
    return spots.filter({ $0.index == index }).first as? T
  }

  /// A look up method for resolving a spot at index as a Spotable object.
  ///
  /// - parameter index: The index of the spot that you are trying to resolve.
  ///
  /// - returns: An optional Spotable object.
  open func spot(at index: Int = 0) -> Spotable? {
    return spots.filter({ $0.index == index }).first
  }

  /// A generic look up method for resolving spots using a closure
  ///
  /// - parameter closure: A closure to perform actions on a spotable object
  ///
  /// - returns: An optional Spotable object
  open func resolve(spot closure: (_ index: Int, _ spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerated()
      where closure(index, spot) {
        return spot
    }
    return nil
  }

  // MARK: - Notifications

  /// Handle rotation for views that are not on screen.
  ///
  /// - parameter notification: A notification containing the new size.
  func deviceDidRotate(_ notification: Notification) {
    if let userInfo = (notification as NSNotification).userInfo as? [String : Any],
      let rotationSize = userInfo["size"] as? RotationSize, view.window == nil {
      configure(withSize: rotationSize.size)
    }
  }

  // MARK: - View Life Cycle

  /// Called after the spot controller's view is loaded into memory.
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(scrollView)
    scrollView.frame = view.bounds
    scrollView.alwaysBounceVertical = true
    scrollView.clipsToBounds = true
    scrollView.delegate = self

    setupSpots()

    Controller.configure?(scrollView)
  }

  /// Notifies the spot controller that its view is about to be added to a view hierarchy.
  ///
  /// - parameter animated: If true, the view is being added to the window using an animation.
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let tabBarController = self.tabBarController, tabBarController.tabBar.isTranslucent {
        scrollView.contentInset.bottom = tabBarController.tabBar.frame.size.height
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
    }
#if os(iOS)
    guard let _ = refreshDelegate, refreshControl.superview == nil
      else { return }

    refreshControl.addTarget(self, action: #selector(refreshSpots(_:)), for: .valueChanged)
    scrollView.insertSubview(refreshControl, at: 0)
#endif
  }

  /// Configure scrollview and composite views with new size.
  ///
  /// - parameter size: The size that should be used to configure the views.
  func configure(withSize size: CGSize) {
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

  /// Notifies the container that the size of tis view is about to change.
  ///
  /// - parameter size:        The new size for the container’s view.
  /// - parameter coordinator: The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    #if os(iOS)
      guard spots_shouldAutorotate() else { return }
    #endif

    coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.configure(withSize: size)
      }) { (UIViewControllerTransitionCoordinatorContext) in
        self.configure(withSize: size)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue),
                                                                  object: nil,
                                                                  userInfo: ["size" : RotationSize(size: size)])
    }
  }


  /// Set up Spotable objects.
  ///
  /// - parameter animated: An optional animation closure that is invoked when setting up the spot.
  open func setupSpots(animated: ((_ view: UIView) -> Void)? = nil) {
    var yOffset: CGFloat = 0.0
    compositeSpots = [:]
    spots.enumerated().forEach { index, spot in
      setupSpot(at: index, spot: spot)
      scrollView.contentView.addSubview(spot.render())
      animated?(spot.render())
      (spot as? CarouselSpot)?.layout.yOffset = yOffset
      yOffset += spot.render().frame.size.height
    }
  }

  /// Set up Spot at index
  ///
  /// - parameter index: The index of the Spotable object
  /// - parameter spot:  The spotable object that is going to be setup
  open func setupSpot(at index: Int, spot: Spotable) {
    spot.render().bounds.size.width = view.bounds.width
    spot.render().frame.origin.x = 0.0
    spot.spotsCompositeDelegate = self
    spots[index].component.index = index
    spot.registerAndPrepare()
    spot.setup(scrollView.frame.size)
    spot.component.size = CGSize(
      width: view.frame.size.width,
      height: ceil(spot.render().frame.height))

    if !spot.items.isEmpty {
      spot.render().layoutIfNeeded()
    }
  }

  #if os(iOS)
  /// Refresh action for UIRefreshControl
  ///
  /// - parameter refreshControl: The refresh control used to refresh the controller.
  open func refreshSpots(_ refreshControl: UIRefreshControl) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.refreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif
}

// MARK: - Private methods

/// An extension with private methods on Controller
extension Controller {

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of the component belonging to the Spotable object at that index.
  ///
  /// - returns: A Component object at index path.
  fileprivate func component(at indexPath: IndexPath) -> Component {
    return spot(at: indexPath).component
  }

  /// Resolve spot at index path.
  ///
  /// - parameter indexPath: The index path of the spotable object.
  ///
  /// - returns: A Spotable object.
  fileprivate func spot(at indexPath: IndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
