import Cocoa

public class SpotsController: NSViewController, SpotsProtocol {

  public static var configure: ((container: SpotsScrollView) -> Void)?

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

  public var stateCache: SpotCache?

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then { [unowned self] in
    $0.autoresizingMask = [.ViewWidthSizable,.ViewHeightSizable]
//    $0.delegate = self
  }

  /**
   - Parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)!
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
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = NSView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
  }

  public override func viewDidLoad() {
    view.wantsLayer = true
    view.layer = CALayer()
    view.addSubview(spotsScrollView)

    spotsScrollView.frame = view.frame
    setupSpots()
    SpotsController.configure?(container: spotsScrollView)
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
   */
  public func setupSpots(animated: ((view: RegularView) -> Void)? = nil) {
    spots.enumerate().forEach { index, spot in
      spots[index].index = index
      spotsScrollView.spotsContentView.addSubview(spot.render())
      //spot.prepare()
      spot.setup(CGSize(width: spotsScrollView.frame.width,
        height: spot.spotHeight() ?? 0))
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
      animated?(view: spot.render())
    }
  }
}