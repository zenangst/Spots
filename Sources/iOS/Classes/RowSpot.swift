import UIKit
import Brick

/// A RowSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class RowSpot: NSObject, Gridable {
  public static var layoutTrait: LayoutTrait = LayoutTrait([:])


  /**
   *  Keys for meta data lookup
   */
  public struct Key {
    /// The key for minimum interitem spacing
    public static let minimumInteritemSpacing = "item-spacing"
    /// The key for minimum line spacing
    public static let minimumLineSpacing = "line-spacing"
  }

  /**
   *  Default configuration values for RowSpot
   */
  public struct Default {
    /// Default top section inset
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default left section inset
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default bottom section inset
    public static var sectionInsetBottom: CGFloat = 0.0
    /// Default minimum interitem spacing
    public static var minimumInteritemSpacing: CGFloat = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: CGFloat = 0.0
    /// Default left section inset
    public static var contentInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var contentInsetRight: CGFloat = 0.0
  }

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
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in collectionView.visibleCells {
        configure(cell)
      }
    }
  }

  /// A SpotsDelegate that is used for the RowSpot
  open weak var delegate: SpotsDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the RowSpot
  open fileprivate(set) var stateCache: StateCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

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
    var component = component
    component.span = 1

    self.component = component

    if self.component.layoutTrait == nil {
      self.component.layoutTrait = type(of: self).layoutTrait
    }

    super.init()
    self.userInterface = collectionView
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = Component.Kind.Row.string
    }

    registerDefault(view: RowSpotCell.self)
    registerComposite(view: GridComposite.self)
    prepareItems()
    configureLayout()
    configureCollectionView()

    if RowSpot.views.composite == nil {
      RowSpot.views.composite = Registry.Item.classType(GridComposite.self)
    }
  }

  /// A convenience init for initializing a RowSpot with a title and a kind.
  ///
  ///  - parameter title: A string that is used as a title for the RowSpot.
  ///  - parameter kind:  An identifier to determine which kind should be set on the Component.
  ///
  /// - returns: An initialized row spot with computed component using title and kind.
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ""))
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

  /// A convenience initializer for RowSpot with base configuration.
  ///
  /// - parameter component:   A Component.
  /// - parameter top:         Top section inset.
  /// - parameter left:        Left section inset.
  /// - parameter bottom:      Bottom section inset.
  /// - parameter right:       Right section inset.
  /// - parameter itemSpacing: The item spacing used in the flow layout.
  /// - parameter lineSpacing: The line spacing used in the flow layout.
  ///
  /// - returns: An initialized row spot with configured layout.
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /// Configure section insets and layout spacing for the UICollectionViewFlow using component meta data
  func configureLayout() {
    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(GridableMeta.Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridableMeta.Key.minimumLineSpacing, Default.minimumLineSpacing)
    collectionView.contentInset.left = component.meta(GridableMeta.Key.contentInsetLeft, Default.contentInsetLeft)
    collectionView.contentInset.right = component.meta(GridableMeta.Key.contentInsetRight, Default.contentInsetRight)
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
