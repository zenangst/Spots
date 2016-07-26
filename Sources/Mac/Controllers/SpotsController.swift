import Cocoa

public enum SpotsControllerBackground {
  case Regular, Dynamic
}

public class SpotsController: NSViewController, SpotsProtocol {

  public static var configure: ((container: SpotsScrollView) -> Void)?
  let KVOWindowContext = UnsafeMutablePointer<()>(nil)

  /// A collection of Spotable objects
  public var spots: [Spotable] {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A convenience method for resolving the first spot
  public var spot: Spotable? {
    get { return spot(0, Spotable.self) }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  public var refreshPositions = [CGFloat]()

  /// An optional SpotCache used for view controller caching
  public var stateCache: SpotCache?

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: dispatch_source_t!
  #endif

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then {
    $0.autoresizingMask = [ .ViewWidthSizable, .ViewHeightSizable ]
  }

  /// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  /// A bool value to indicate if the SpotsController is refeshing
  public var refreshing = false

  private let backgroundType: SpotsControllerBackground

  /**
   - Parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = [], backgroundType: SpotsControllerBackground = .Regular) {
    self.spots = spots
    self.backgroundType = backgroundType
    super.init(nibName: nil, bundle: nil)!

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SpotsController.scrollViewDidScroll(_:)), name: NSScrollViewDidLiveScrollNotification, object: spotsScrollView)
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
   deinit
   */
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    spots.forEach { $0.spotsDelegate = nil }
    spotsDelegate = nil
    spotsScrollDelegate = nil
  }

  /**
   Returns an object initialized from data in a given unarchiver

   - Parameter coder: An unarchiver object.
   - Returns: self, initialized using the data in decoder..
   */
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

  /**
   Instantiates a view from a nib file and sets the value of the view property.
   */
  public override func loadView() {
    let view: NSView

    switch backgroundType {
    case .Regular:
      view = NSView()
    case .Dynamic:
      let visualEffectView = NSVisualEffectView()
      visualEffectView.blendingMode = .BehindWindow
      view = visualEffectView
    }

    view.autoresizingMask = .ViewWidthSizable
    view.autoresizesSubviews = true
    self.view = view
  }

  /**
   Called after the view controller’s view has been loaded into memory.
   */
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)
    spotsScrollView.hasVerticalScroller = true
    setupSpots()
    SpotsController.configure?(container: spotsScrollView)
  }

  public override func viewDidAppear() {
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
    spotsScrollView.layoutSubtreeIfNeeded()
    closure?()
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
   */
  public func setupSpots(animated: ((view: View) -> Void)? = nil) {
    spots.enumerate().forEach { index, spot in

      var height = spot.spotHeight()
      if let componentSize = spot.component.size where componentSize.height > height {
        height = componentSize.height
      }

      spots[index].index = index
      spotsScrollView.spotsContentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(CGSize(width: view.frame.width,
        height: height))
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
      animated?(view: spot.render())
    }
  }

  public override func viewDidLayout() {
    super.viewDidLayout()
    for spot in spots {
      spot.layout(CGSize(width: view.frame.width,
        height: spot.spotHeight() ?? 0))
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

  func scrollViewDidScroll(notification: NSNotification) {
    guard let scrollView = notification.object as? SpotsScrollView,
      delegate = spotsScrollDelegate,
      _ = NSApplication.sharedApplication().mainWindow
      else { return }

    let offset = scrollView.contentOffset
    let totalHeight = (scrollView.documentView as? NSView)?.frame.size.height ?? 0
    let shouldFetch = !refreshing &&
      offset.y > 0 &&
      offset.y + scrollView.frame.size.height > totalHeight - scrollView.frame.size.height &&
      !refreshPositions.contains(scrollView.spotsContentView.visibleRect.size.height)

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
      refreshPositions.append(scrollView.spotsContentView.visibleRect.size.height)
      refreshing = true
      delegate.spotDidReachEnd {
        self.refreshing = false
      }
    }
  }
}
