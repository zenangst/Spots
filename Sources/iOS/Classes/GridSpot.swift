import UIKit
import Brick

/// A GridSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class GridSpot: NSObject, Gridable {

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
   *  Default configuration values for GridSpot
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
  }

  /// A Registry object that holds identifiers and classes for cells used in the GridSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the GridSpot
  open static var headers = Registry()

  /// A component struct used as configuration and data source for the GridSpot
  open var component: Component

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)?

  /// A SpotsCompositeDelegate for the GridSpot, used to access composite spots
  open weak var spotsCompositeDelegate: SpotsCompositeDelegate?

  /// A SpotsDelegate that is used for the GridSpot
  open weak var spotsDelegate: SpotsDelegate?

  /// A computed variable for adapters
  open var adapter: SpotAdapter? {
    return collectionAdapter
  }

  /// A collection adapter that is the data source and delegate for the GridSpot
  open lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A SpotCache for the GridSpot
  open fileprivate(set) var stateCache: SpotCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  /// A UICollectionView, used as the main UI component for a GridSpot
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.dataSource = self.collectionAdapter
    collectionView.delegate = self.collectionAdapter
    collectionView.isScrollEnabled = false

    return collectionView
  }()

  /**
   A required initializer to instantiate a GridSpot with a component

   - parameter component: A component
   */
  public required init(component: Component) {
    self.component = component
    super.init()

    self.configureLayout()

    registerDefault(view: GridSpotCell.self)
    registerComposite(view: GridComposite.self)

    if GridSpot.views.composite == nil {
      GridSpot.views.composite =  Registry.Item.classType(GridComposite.self)
    }
  }

  /**
   A convenience init for initializing a Gridspot with a title and a kind

   - parameter title: A string that is used as a title for the GridSpot
   - parameter kind:  An identifier to determine which kind should be set on the Component
   */
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? "grid"))
  }

  /**
   Instantiate a GridSpot with a cache key

   - parameter cacheKey: A unique cache key for the Spotable object
   */
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  /**
   A convenience initializer for GridSpot with base configuration

   - parameter component:   A Component
   - parameter top:         Top section inset
   - parameter left:        Left section inset
   - parameter bottom:      Bottom section inset
   - parameter right:       Right section inset
   - parameter itemSpacing: The item spacing used in the flow layout
   - parameter lineSpacing: The line spacing used in the flow layout
   */
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /**
   Configure section insets and layout spacing for the UICollectionViewFlow using component meta data
   */
  func configureLayout() {
    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(GridableMeta.Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridableMeta.Key.minimumLineSpacing, Default.minimumLineSpacing)
  }
}
