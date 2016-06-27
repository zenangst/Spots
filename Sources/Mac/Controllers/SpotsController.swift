import Cocoa

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

  /**
   - Parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)!
  }

  /**
   deinit
   */
  deinit {
    view.removeObserver(self, forKeyPath: "window", context: KVOWindowContext)
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
   Returns an object initialized from data in a given unarchiver

   - Parameter coder: An unarchiver object.
   - Returns: self, initialized using the data in decoder..
   */
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
   This message is sent to the receiver when the value at the specified key path relative to the given object has changed.

   - Parameter keyPath: The key path, relative to object, to the value that has changed.
   - Parameter object:  The source object of the key path keyPath.
   - Parameter change:  A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object.
   - Parameter context: The value that was provided when the receiver was registered to receive key-value observation notifications.
   */
  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let themeFrame = view.superview
      where keyPath == "window" && context == KVOWindowContext else { return }

    setupSpots()
    SpotsController.configure?(container: spotsScrollView)

    for case let grid as Gridable in spots {
      grid.layout.invalidateLayout()
    }
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
    view = NSView()
    view.autoresizingMask = .ViewWidthSizable
    view.autoresizesSubviews = true
    view.addObserver(self, forKeyPath: "window", options: .Old, context: KVOWindowContext)
  }

  /**
   Called after the view controller’s view has been loaded into memory.
   */
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
   */
  public func setupSpots(animated: ((view: View) -> Void)? = nil) {
    spots.enumerate().forEach { index, spot in
      spots[index].index = index
      spotsScrollView.spotsContentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(CGSize(width: view.frame.width,
        height: spot.spotHeight() ?? 0))
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
      animated?(view: spot.render())
    }
  }

  public override func viewDidLayout() {
    super.viewDidLayout()
    for case let spot as Spotable in spots {
      spot.setup(CGSize(width: view.frame.width,
        height: spot.spotHeight() ?? 0))
    }
  }

  public func deselectAllExcept(selectedSpot: Spotable) {
    for spot in spots {
      if selectedSpot.render() != spot.render() {
        spot.deselect()
      }
    }
  }
}
