import UIKit
import Sugar
import Brick

/// A CarouselSpot, a collection view based Spotable object that lays out its items in a horizontal order
public class CarouselSpot: NSObject, Gridable {

  /**
   *  A struct that holds keys that is used when mapping meta data to configuration methods
   */
  public struct Key {
    public static let dynamicSpan = "dynamic-span"
  }

  /**
   *  A struct with default values for the CarouselSpot
   */
  public struct Default {
    public static var dynamicSpan: Bool = false
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
    public static var minimumInteritemSpacing: CGFloat = 0.0
    public static var minimumLineSpacing: CGFloat = 0.0
  }

  /// A boolean value that affects the sizing of items when using span, if enabled and the item count is less than the span, the CarouselSpot will even out the space between the items to align them
  public var dynamicSpan = false

  /// Indicator to calculate the height based on content
  public var usesDynamicHeight = true

  /// A Registry object that holds identifiers and classes for cells used in the CarouselSpot
  public static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the CarouselSpot
  public static var headers = Registry().then {
    $0.defaultItem = Registry.Item.classType(CarouselSpotHeader.self)
  }

  /// A SpotCache for the CarouselSpot
  public private(set) var stateCache: SpotCache?

  /// A component struct used as configuration and data source for the CarouselSpot
  public var component: Component {
    willSet(value) {
      #if os(iOS)
        dynamicSpan ?= component.meta(Key.dynamicSpan, Default.dynamicSpan)
        if component.items.count > 1 && component.span > 0 {
          pageControl.numberOfPages = Int(floor(CGFloat(component.items.count) / component.span))
        }
      #endif
    }
  }

  #if os(iOS)
  /// A boolean value that configures the collection views pagination
  public var paginate = false {
    willSet(newValue) {
      if component.span == 1 {
        collectionView.pagingEnabled = newValue
      }
    }
  }

  /// Determines how the CarouselSpot should handle pagination, if enabled, it will snap to each item in the carousel
  public var paginateByItem: Bool = false
  #endif

  /// A boolean value that determines if the CarouselSpot should show a page indicator
  public var pageIndicator: Bool = false {
    willSet(value) {
      if value {
        pageControl.width = backgroundView.frame.width
        collectionView.backgroundView?.addSubview(pageControl)
      } else {
        pageControl.removeFromSuperview()
      }
    }
  }

  /// A configuration closure
  public var configure: (SpotConfigurable -> Void)?

  public weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?
  /// A SpotsCompositeDelegate for the CarouselSpot, used to access composite spots
  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  /// A SpotsDelegate that is used for the CarouselSpot
  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }
  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  /// A UIPageControl, enable by setting pageIndicator to true
  public lazy var pageControl = UIPageControl().then {
    $0.frame.size.height = 22
    $0.pageIndicatorTintColor = UIColor.lightGrayColor()
    $0.currentPageIndicatorTintColor = UIColor.grayColor()
  }

  /// A custom UICollectionViewFlowLayout
  public lazy var layout: CollectionLayout = GridableLayout().then {
    $0.scrollDirection = .Horizontal
  }

  /// A UICollectionView, used as the main UI component for a CarouselSpot
  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
    $0.dataSource = self.collectionAdapter
    $0.delegate = self.collectionAdapter
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundView = self.backgroundView
    $0.alwaysBounceHorizontal = true
  }

  /// The collection views background view
  public lazy var backgroundView = UIView()

  /**
   A required initializer to instantiate a CarouselSpot with a component

   - parameter component: A component

   - returns: A CarouselSpot object
   */
  public required init(component: Component) {
    self.component = component
    super.init()
    configureLayout()
    registerDefault(view: CarouselSpotCell.self)
    registerComposite(view: CarouselComposite.self)
  }

  /**
   A convenience initializer for CarouselSpot with base configuration

   - parameter component:   A Component
   - parameter top:         Top section inset
   - parameter left:        Left section inset
   - parameter bottom:      Bottom section inset
   - parameter right:       Right section inset
   - parameter itemSpacing: The item spacing used in the flow layout
   - parameter lineSpacing: The line spacing used in the flow layout

   - returns: A CarouselSpot object
   */
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /**
   Instantiate a CarouselSpot with a cache key

   - parameter cacheKey: A unique cache key for the Spotable object

   - returns: A CarouselSpot object
   */
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  /**
   Setup Spotable component with base size

   - parameter size: The size of the superview
   */
  public func setup(size: CGSize) {
    collectionView.frame.size = size

    if collectionView.contentSize.height > 0 {
      collectionView.height = collectionView.contentSize.height
    } else {
      collectionView.height = component.items.sort({ $0.size.height > $1.size.height }).first?.size.height ?? 0

      if collectionView.height > 0 {
        collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    #if os(iOS)
    paginate ?= component.meta("paginate", type: Bool.self)
    pageIndicator ?= component.meta("pageIndicator", type: Bool.self)
    #endif

    if !component.header.isEmpty {
      let resolve = self.dynamicType.headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(view: collectionView, layout: layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    guard pageIndicator else { return }
    layout.sectionInset.bottom = layout.sectionInset.bottom + pageControl.height
    collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
    pageControl.frame.origin.y = collectionView.height - pageControl.height
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
    dynamicSpan = component.meta(Key.dynamicSpan, false)
  }
}
