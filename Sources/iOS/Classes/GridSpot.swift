// swiftlint:disable weak_delegate

import UIKit

/// A GridSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class GridSpot: NSObject, Gridable {

  public static var layout = Layout(span: 0.0)

  /// A Registry object that holds identifiers and classes for cells used in the GridSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the GridSpot
  open static var headers = Registry()

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  /// A component struct used as configuration and data source for the GridSpot
  open var component: ComponentModel

  /// A configuration closure
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A SpotsDelegate that is used for the GridSpot
  open weak var delegate: SpotsDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the GridSpot
  open fileprivate(set) var stateCache: StateCache?

  /// A UICollectionView, used as the main UI component for a GridSpot
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false

    return collectionView
    }()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// A required initializer to instantiate a GridSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized grid spot with component.
  public required init(component: ComponentModel) {
    self.component = component

    if self.component.layout == nil {
      self.component.layout = type(of: self).layout
    }

    super.init()
    self.userInterface = collectionView
    self.component.layout?.configure(spot: self)
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = ComponentModel.Kind.grid.string
    }

    registerDefault(view: GridSpotCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    configureCollectionView()

    if GridSpot.views.composite == nil {
      GridSpot.views.composite =  Registry.Item.classType(GridComposite.self)
    }
  }

  /// A convenience init for initializing a Gridspot with a title and a kind.
  ///
  ///  - parameter title: A string that is used as a title for the GridSpot.
  ///  - parameter kind:  An identifier to determine which kind should be set on the ComponentModel.
  ///
  /// - returns: An initialized grid spot with computed component using title and kind.
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: ComponentModel(title: title, kind: kind ?? "", span: 0.0))
  }

  /// Instantiate a GridSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object
  ///
  /// - returns: An initialized grid spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  /// Configure collection view with data source, delegate and background view
  public func configureCollectionView() {
    register()
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }
}
