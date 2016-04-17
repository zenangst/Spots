import UIKit
import Sugar
import Brick

public class SpotsController: UIViewController, UIScrollViewDelegate {

  public static var configure: ((container: SpotsScrollView) -> Void)?

  public private(set) var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero
  public private(set) var spots: [Spotable]

  public var refreshPositions = [CGFloat]()
  public var refreshing = false

  weak public var spotsDelegate: SpotsDelegate? {
    didSet { spots.forEach { $0.spotsDelegate = spotsDelegate } }
  }

  public var spot: Spotable {
    get { return spot(0, Spotable.self)! }
  }

  weak public var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      refreshControl.hidden = spotsRefreshDelegate == nil
    }
  }

  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then { [unowned self] in
    $0.frame = self.view.frame
    $0.alwaysBounceVertical = true
    $0.clipsToBounds = true
    $0.delegate = self
  }

  public lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshSpots(_:)), forControlEvents: .ValueChanged)

    return refreshControl
  }()

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

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //MARK: - View Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)

    spots.enumerate().forEach { index, spot in
      spots[index].index = index
      spot.render().optimize()
      spotsScrollView.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(spotsScrollView.frame.size)
      spot.component.size = CGSize(
        width: view.width,
        height: ceil(spot.render().height))
    }

    SpotsController.configure?(container: spotsScrollView)
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    spotsScrollView.forceUpdate = true

    if let tabBarController = self.tabBarController
      where tabBarController.tabBar.translucent {
        spotsScrollView.contentInset.bottom = tabBarController.tabBar.height
        spotsScrollView.scrollIndicatorInsets.bottom = spotsScrollView.contentInset.bottom
    }

    guard let _ = spotsRefreshDelegate where refreshControl.superview == nil
      else { return }

    spotsScrollView.insertSubview(refreshControl, atIndex: 0)
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }
}

// MARK: - Public SpotController methods

extension SpotsController {

  /**
   - Parameter index: The index of the spot that you are trying to resolve
   - Parameter type: The generic type for the spot you are trying to resolve
   */
  public func spot<T>(index: Int = 0, _ type: T.Type) -> T? {
    return spots.filter({ $0.index == index }).first as? T
  }

  /**
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
   - Parameter includeElement: A filter predicate to find a spot
   */
  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  /**
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(completion: (() -> Void)? = nil) {
    var spotsLeft = spots.count

    dispatch { [weak self] in
      self?.spots.forEach { spot in
        spot.reload([]) {
          spotsLeft -= 1

          if spotsLeft == 0 {
            completion?()
          }
        }
      }
    }
  }

  /**
   - Parameter spotAtIndex: The index of the spot that you want to perform updates on
   - Parameter closure: A transform closure to perform the proper modification to the target spot before updating the internals
   */
  public func update(spotAtIndex index: Int = 0, @noescape _ closure: (spot: Spotable) -> Void) {
    guard let spot = spot(index, Spotable.self) else { return }
    closure(spot: spot)
    spot.refreshIndexes()
    spot.prepare()
    spot.setup(spotsScrollView.bounds.size)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index, Spotable.self)?.reload([index]) {
        weakSelf.spotsScrollView.setNeedsDisplay()
        weakSelf.spotsScrollView.forceUpdate = true
      }
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(item: ViewModel, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.append(item) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(items: [ViewModel], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.append(items) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(items: [ViewModel], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.prepend(items)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to insert into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(item: ViewModel, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.insert(item, index: index)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to update
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(item: ViewModel, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.update(item, index: index)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter indexes: An integer array of indexes that you want to update
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(indexes indexes: [Int], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.reload(indexes) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(index: Int, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.delete(index) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter indexes: A collection of indexes for view models that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(indexes indexes: [Int], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spot(spotIndex, Spotable.self)?.delete(indexes) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }


  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }

  /**
   - Parameter index: The index of the spot that you want to scroll
   - Parameter includeElement: A filter predicate to find a view model
   */
  public func scrollTo(spotIndex index: Int = 0, @noescape includeElement: (ViewModel) -> Bool) {
    guard let itemY = spot(index, Spotable.self)?.scrollTo(includeElement) else { return }

    if spot(index, Spotable.self)?.spotHeight() > spotsScrollView.height - spotsScrollView.contentInset.bottom {
      let y = itemY - spotsScrollView.height + spotsScrollView.contentInset.bottom
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /**
   - Parameter animated: A boolean value to determine if you want to perform the scrolling with or without animation
   */
  public func scrollToBottom(animated: Bool) {
    let y = spotsScrollView.contentSize.height - spotsScrollView.height + spotsScrollView.contentInset.bottom
    spotsScrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
}

// MARK: - Private methods

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
