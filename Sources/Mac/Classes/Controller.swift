import Cocoa

public enum ControllerBackground {
  case regular, dynamic
}

open class Controller: NSViewController, SpotsProtocol, CompositeDelegate {

  /// A closure that is called when the controller is reloaded with components
  public static var spotsDidReloadComponents: ((Controller) -> Void)?

  open static var configure: ((_ container: SpotsScrollView) -> Void)?

  /// A collection of Spotable objects
  open var spots: [Spotable] {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.didChange(spots: spots)
    }
  }

  /// A collection of composite Spotable objects.
  open var compositeSpots: [CompositeSpot] {
    didSet {
      for compositeSpot in compositeSpots {
        compositeSpot.spot.delegate = delegate
      }
    }
  }

  /// A convenience method for resolving the first spot
  open var spot: Spotable? {
    get { return spot(at: 0) }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  open var refreshPositions = [CGFloat]()

  /// An optional StateCache used for view controller caching
  open var stateCache: StateCache?

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject?
  #endif

  /// A delegate for when an item is tapped within a Spot
  weak public var delegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.delegate = delegate }
      delegate?.didChange(spots: spots)
    }
  }

  /// A custom scroll view that handles the scrolling for all internal scroll views
  public var scrollView: SpotsScrollView = SpotsScrollView()

  /// A scroll delegate for handling didReachBeginning and didReachEnd
  weak open var scrollDelegate: ScrollDelegate?

  /// A bool value to indicate if the Controller is refeshing
  open var refreshing = false

  fileprivate let backgroundType: ControllerBackground

  /**
   - parameter spots: An array of Spotable objects
   - parameter backgroundType: The type of background that the Controller should use, .Regular or .Dynamic
   */
  public required init(spots: [Spotable] = [], backgroundType: ControllerBackground = .regular) {
    self.compositeSpots = []
    self.spots = spots
    self.backgroundType = backgroundType
    super.init(nibName: nil, bundle: nil)!

    NotificationCenter.default.addObserver(self, selector: #selector(Controller.scrollViewDidScroll(_:)), name: NSNotification.Name.NSScrollViewDidLiveScroll, object: scrollView)

    NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(_:)), name: NSNotification.Name.NSWindowDidResize, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(windowDidEndLiveResize(_:)), name: NSNotification.Name.NSWindowDidEndLiveResize, object: nil)
  }

  /**
   - parameter cacheKey: A key that will be used to identify the StateCache
   */
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
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
   deinit
   */
  deinit {
    NotificationCenter.default.removeObserver(self)
    spots.forEach { $0.delegate = nil }
    delegate = nil
    scrollDelegate = nil
  }

  /**
   Returns an object initialized from data in a given unarchiver

   - parameter coder: An unarchiver object.
   */
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

  /**
   A generic look up method for resolving spots using a closure

   - parameter closure: A closure to perform actions on a spotable object

   - returns: An optional Spotable object
   */
  public func resolve(spot closure: (_ index: Int, _ spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerated()
      where closure(index, spot) {
        return spot
    }
    return nil
  }

  /**
   Instantiates a view from a nib file and sets the value of the view property.
   */
  open override func loadView() {
    let view: NSView

    switch backgroundType {
    case .regular:
      view = NSView()
    case .dynamic:
      let visualEffectView = NSVisualEffectView()
      visualEffectView.blendingMode = .behindWindow
      view = visualEffectView
    }

    view.autoresizingMask = .viewWidthSizable
    view.autoresizesSubviews = true
    self.view = view
  }

  /**
   Called after the view controller’s view has been loaded into memory.
   */
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(scrollView)
    scrollView.hasVerticalScroller = true
    scrollView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]

    setupSpots()
    Controller.configure?(scrollView)
  }

  open override func viewDidAppear() {
    super.viewDidAppear()

    for spot in spots {
      spot.layout(scrollView.frame.size)
    }
  }

  public func reloadSpots(spots: [Spotable], closure: (() -> Void)?) {
    for spot in self.spots {
      spot.delegate = nil
      spot.render().removeFromSuperview()
    }
    self.spots = spots
    delegate = nil

    setupSpots()
    closure?()
    scrollView.layoutSubtreeIfNeeded()
  }

  /**
   - parameter animated: An optional animation closure that runs when a spot is being rendered
   */
  public func setupSpots(animated: ((_ view: View) -> Void)? = nil) {
    compositeSpots = []
    spots.enumerated().forEach { index, spot in
      setupSpot(at: index, spot: spot)
      animated?(spot.render())
    }
  }

  public func setupSpot(at index: Int, spot: Spotable) {
    spots[index].component.index = index
    spot.spotsCompositeDelegate = self
    spot.registerAndPrepare()

    var height = spot.computedHeight
    if let componentSize = spot.component.size, componentSize.height > height {
      height = componentSize.height
    }

    spot.setup(CGSize(width: view.frame.width, height: height))
    spot.component.size = CGSize(
      width: view.frame.width,
      height: ceil(spot.render().frame.height))
    scrollView.spotsContentView.addSubview(spot.render())
  }

  open override func viewDidLayout() {
    super.viewDidLayout()
    for spot in spots {
      spot.layout(CGSize(width: view.frame.width,
        height: spot.computedHeight ))
    }
    scrollView.layoutSubtreeIfNeeded()
  }

  public func deselectAllExcept(selectedSpot: Spotable) {
    for spot in spots {
      if selectedSpot.render() != spot.render() {
        spot.deselect()
      }
    }
  }

  public func windowDidResize(_ notification: Notification) {
    for case let spot as Gridable in spots {
      guard spot.component.span > 1 else {
        continue
      }
      
      spot.layout.prepareForTransition(from: spot.layout)
      spot.layout.invalidateLayout()
    }
  }

  public func windowDidEndLiveResize(_ notification: Notification) {
    for case let spot as Gridable in spots {
      guard spot.component.span > 1 else {
        continue
      }

      spot.layout.prepareForTransition(to: spot.layout)
      spot.layout.invalidateLayout()
    }
  }

  open func scrollViewDidScroll(_ notification: NSNotification) {
    guard let scrollView = notification.object as? SpotsScrollView,
      let delegate = scrollDelegate,
      let _ = NSApplication.shared().mainWindow, !refreshing && scrollView.contentOffset.y > 0
      else { return }

    let offset = scrollView.contentOffset
    let totalHeight = scrollView.documentView?.frame.size.height ?? 0
    let multiplier: CGFloat = !refreshPositions.isEmpty
      ? CGFloat(1 + refreshPositions.count)
      : 1.5
    let currentOffset = offset.y + scrollView.frame.size.height
    let shouldFetch = currentOffset > totalHeight - scrollView.frame.size.height * multiplier + scrollView.frame.origin.y &&
      !refreshPositions.contains(currentOffset)

    // Scroll did reach top
    if scrollView.contentOffset.y < 0 &&
      !refreshing {
      refreshing = true
      delegate.didReachBeginning(in: scrollView) {
        self.refreshing = false
      }
    }

    if shouldFetch {
      // Infinite scrolling
      refreshing = true
      refreshPositions.append(currentOffset)
      delegate.didReachEnd(in: scrollView) {
        self.refreshing = false
      }
    }
  }
}
