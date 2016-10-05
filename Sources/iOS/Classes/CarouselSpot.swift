import UIKit
import Brick

/// A CarouselSpot, a collection view based Spotable object that lays out its items in a horizontal order
open class CarouselSpot: NSObject, Gridable {

  /**
   *  A struct that holds keys that is used when mapping meta data to configuration methods
   */
  public struct Key {
    /// Dynamic span key used when looking up meta properties
    public static let dynamicSpan = "dynamic-span"
  }

  /**
   *  A struct with default values for the CarouselSpot
   */
  public struct Default {
    /// Default dynamicSpan value
    public static var dynamicSpan: Bool = false
    /// Default section inset top
    public static var sectionInsetTop: Double = 0.0
    /// Default section inset left
    public static var sectionInsetLeft: Double = 0.0
    /// Default section inset right
    public static var sectionInsetRight: Double = 0.0
    /// Default section inset bottom
    public static var sectionInsetBottom: Double = 0.0
    /// Default default minimum interitem spacing
    public static var minimumInteritemSpacing: Double = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: Double = 0.0
  }

  /// A boolean value that affects the sizing of items when using span, if enabled and the item count is less than the span, the CarouselSpot will even out the space between the items to align them
  open var dynamicSpan = false

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  /// A Registry object that holds identifiers and classes for cells used in the CarouselSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the CarouselSpot
  open static var headers = Registry()

  /// A SpotCache for the CarouselSpot
  open fileprivate(set) var stateCache: SpotCache?

  /// A component struct used as configuration and data source for the CarouselSpot
  open var component: Component {
    willSet(value) {
      #if os(iOS)
        dynamicSpan = component.meta(Key.dynamicSpan, Default.dynamicSpan)
        if component.items.count > 1 && component.span > 0 {
          pageControl.numberOfPages = Int(floor(Double(component.items.count) / component.span))
        }
      #endif
    }
  }

  #if os(iOS)
  /// A boolean value that configures the collection views pagination
  open var paginate = false {
    willSet(newValue) {
      if component.span == 1 {
        collectionView.isPagingEnabled = newValue
      }
    }
  }

  /// Determines how the CarouselSpot should handle pagination, if enabled, it will snap to each item in the carousel
  open var paginateByItem: Bool = false
  #endif

  /// A boolean value that determines if the CarouselSpot should show a page indicator
  open var pageIndicator: Bool = false {
    willSet(value) {
      if value {
        pageControl.frame.size.width = backgroundView.frame.width
        collectionView.backgroundView?.addSubview(pageControl)
      } else {
        pageControl.removeFromSuperview()
      }
    }
  }

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)?

  /// A CarouselScrollDelegate, used when a CarouselSpot scrolls
  open weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?

  /// A SpotsCompositeDelegate for the CarouselSpot, used to access composite spots
  open weak var spotsCompositeDelegate: SpotsCompositeDelegate?

  /// A SpotsDelegate that is used for the CarouselSpot
  open weak var spotsDelegate: SpotsDelegate?

  /// A computed variable for adapters
  open var adapter: SpotAdapter? {
    return collectionAdapter
  }

  /// A collection adapter that is the data source and delegate for the CarouselSpot
  open lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  /// A UIPageControl, enable by setting pageIndicator to true
  open lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.frame.size.height = 22
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.gray

    return pageControl
  }()

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = {
    let layout = GridableLayout()
    layout.scrollDirection = .horizontal

    return layout
  }()

  /// A UICollectionView, used as the main UI component for a CarouselSpot
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.dataSource = self.collectionAdapter
    collectionView.delegate = self.collectionAdapter
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundView = self.backgroundView
    collectionView.alwaysBounceHorizontal = true

    return collectionView
  }()

  /// The collection views background view
  open lazy var backgroundView = UIView()

  /**
   A required initializer to instantiate a CarouselSpot with a component

   - parameter component: A component
   */
  public required init(component: Component) {
    self.component = component
    super.init()
    configureLayout()
    registerDefault(view: CarouselSpotCell.self)
    registerComposite(view: CarouselComposite.self)
    registerDefaultHeader(header: CarouselSpotHeader.self)
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
  open func setup(_ size: CGSize) {
    collectionView.frame.size = size

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = component.items.sorted(by: { $0.size.height > $1.size.height }).first?.size.height ?? 0

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    #if os(iOS)
      if let paginate = component.meta("paginate", type: Bool.self) {
        self.paginate = paginate
      }

      if let pageIndicator = component.meta("paginate", type: Bool.self) {
        self.pageIndicator = pageIndicator
      }
    #endif

    if !component.header.isEmpty {
      let resolve = type(of: self).headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.frame.size.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    guard pageIndicator else { return }
    layout.sectionInset.bottom = layout.sectionInset.bottom + pageControl.frame.size.height
    collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
    pageControl.frame.origin.y = collectionView.frame.size.height - pageControl.frame.size.height
  }

  /**
   Configure section insets and layout spacing for the UICollectionViewFlow using component meta data
   */
  func configureLayout() {
    layout.sectionInset = UIEdgeInsets(
      top: CGFloat(component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop)),
      left: CGFloat(component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft)),
      bottom: CGFloat(component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom)),
      right: CGFloat(component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight)))
    layout.minimumInteritemSpacing = CGFloat(component.meta(GridableMeta.Key.minimumInteritemSpacing, Default.minimumInteritemSpacing))
    layout.minimumLineSpacing = CGFloat(component.meta(GridableMeta.Key.minimumLineSpacing, Default.minimumLineSpacing))
    dynamicSpan = component.meta(Key.dynamicSpan, false)
  }

  /**
   Register default header for the CarouselSpot

   - parameter view: A header view
   */
  func registerDefaultHeader(header view: View.Type) {
    guard type(of: self).headers.storage[type(of: self).headers.defaultIdentifier] == nil else { return }
    type(of: self).headers.defaultItem = Registry.Item.classType(view)
  }
}
