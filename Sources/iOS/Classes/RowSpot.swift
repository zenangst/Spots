// swiftlint:disable weak_delegate

import UIKit

/// A RowSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class RowSpot: NSObject, Gridable {

  public static var layout: Layout = Layout(span: 1.0)

  /// A Registry object that holds identifiers and classes for cells used in the RowSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the RowSpot
  open static var headers = Registry()

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  /// A component struct used as configuration and data source for the RowSpot
  open var component: Component

  /// A configuration closure
  open var configure: ((ContentConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A SpotsDelegate that is used for the RowSpot
  open weak var delegate: SpotsDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the RowSpot
  open fileprivate(set) var stateCache: StateCache?

  /// A UICollectionView, used as the main UI component for a RowSpot
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.isScrollEnabled = false

    return collectionView
    }()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// A required initializer to instantiate a RowSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized row spot with component.
  public required init(component: Component) {
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
      self.component.kind = Component.Kind.row.string
    }

    registerDefault(view: RowSpotCell.self)
    registerComposite(view: GridComposite.self)
    prepareItems()
    configureCollectionView()

    if RowSpot.views.composite == nil {
      RowSpot.views.composite = Registry.Item.classType(GridComposite.self)
    }
  }

  /// Instantiate a RowSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object
  ///
  /// - returns: An initialized row spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  /// Configure collection view with data source, delegate and background view
  public func configureCollectionView() {
    register()
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
  }
}
