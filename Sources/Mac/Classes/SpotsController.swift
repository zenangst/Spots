import Cocoa

public enum SpotsControllerBackground {
  case regular, dynamic
}

open class SpotsController: NSViewController, SpotsProtocol {

  open static var configure: ((_ container: SpotsScrollView) -> Void)?
  let KVOWindowContext: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(mutating: nil)

  /// A collection of Spotable objects
  open var spots: [Spotable] {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  open var compositeSpots: [Int : [Int : [Spotable]]] {
    didSet {
      for (_, items) in compositeSpots {
        for (_, container) in items.enumerated() {
          container.1.forEach { $0.spotsDelegate = spotsDelegate }
        }
      }
    }
  }

  /// A convenience method for resolving the first spot
  open var spot: Spotable? {
    get { return spot(at: 0) }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  open var refreshPositions = [CGFloat]()

  /// An optional SpotCache used for view controller caching
  open var stateCache: SpotCache?

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject!
  #endif

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy public var spotsScrollView: SpotsScrollView = {
    let spotsScrollView = SpotsScrollView()
    spotsScrollView.autoresizingMask = [ .viewWidthSizable, .viewHeightSizable ]

    return spotsScrollView
  }()

  /// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
  weak open var spotsScrollDelegate: SpotsScrollDelegate?

  /// A bool value to indicate if the SpotsController is refeshing
  open var refreshing = false

  fileprivate let backgroundType: SpotsControllerBackground

  /**
   - parameter spots: An array of Spotable objects
   - parameter backgroundType: The type of background that the SpotsController should use, .Regular or .Dynamic
   */
  public required init(spots: [Spotable] = [], backgroundType: SpotsControllerBackground = .regular) {
    self.compositeSpots = [:]
    self.spots = spots
    self.backgroundType = backgroundType
    super.init(nibName: nil, bundle: nil)!

    NotificationCenter.default.addObserver(self, selector: #selector(SpotsController.scrollViewDidScroll(_:)), name: NSNotification.Name.NSScrollViewDidLiveScroll, object: spotsScrollView)
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
    spots.forEach { $0.spotsDelegate = nil }
    spotsDelegate = nil
    spotsScrollDelegate = nil
  }

  /**
   Returns an object initialized from data in a given unarchiver

   - parameter coder: An unarchiver object.
   */
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
   A generic look up method for resolving spots based on index

   - parameter index: The index of the spot that you are trying to resolve
   - parameter type: The generic type for the spot you are trying to resolve

   - returns: An optional Spotable object
   */
  public func spot<T>(at index: Int = 0, _ type: T.Type) -> T? {
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
    view.addSubview(spotsScrollView)
    spotsScrollView.hasVerticalScroller = true
    setupSpots()
    SpotsController.configure?(spotsScrollView)
  }

  open override func viewDidAppear() {
    super.viewDidAppear()

    for spot in spots {
      spot.layout(spotsScrollView.frame.size)
    }
    spotsScrollView.forceUpdate = true
  }

  public func reloadSpots(spots: [Spotable], closure: (() -> Void)?) {
    for spot in self.spots {
      spot.spotsDelegate = nil
      spot.render().removeFromSuperview()
    }
    self.spots = spots
    spotsDelegate = nil

    setupSpots()
    closure?()
    spotsScrollView.layoutSubtreeIfNeeded()
  }

  /**
   - parameter animated: An optional animation closure that runs when a spot is being rendered
   */
  public func setupSpots(_ animated: ((_ view: View) -> Void)? = nil) {
    compositeSpots = [:]
    spots.enumerated().forEach { index, spot in
      setupSpot(at: index, spot: spot)
      animated?(spot.render())
    }
  }

  public func setupSpot(at index: Int, spot: Spotable) {
    #if !os(OSX)
      spot.spotsCompositeDelegate = self
    #endif

    var height = spot.computedHeight
    if let componentSize = spot.component.size, componentSize.height > height {
      height = componentSize.height
    }

    spots[index].component.index = index
    spot.registerAndPrepare()
    spotsScrollView.spotsContentView.addSubview(spot.render())
    spot.setup(CGSize(width: view.frame.width, height: height))
    spot.component.size = CGSize(
      width: view.frame.width,
      height: ceil(spot.render().frame.height))
  }

  open override func viewDidLayout() {
    super.viewDidLayout()
    for spot in spots {
      spot.layout(CGSize(width: view.frame.width,
        height: spot.computedHeight ))
    }
    spotsScrollView.layoutSubtreeIfNeeded()
  }

  public func deselectAllExcept(selectedSpot: Spotable) {
    for spot in spots {
      if selectedSpot.render() != spot.render() {
        spot.deselect()
      }
    }
  }

  open func scrollViewDidScroll(_ notification: NSNotification) {
    guard let scrollView = notification.object as? SpotsScrollView,
      let delegate = spotsScrollDelegate,
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
      delegate.spotDidReachBeginning {
        self.refreshing = false
      }
    }

    if shouldFetch {
      // Infinite scrolling
      refreshing = true
      refreshPositions.append(currentOffset)
      delegate.spotDidReachEnd {
        self.refreshing = false
      }
    }
  }
}
