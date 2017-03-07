// swiftlint:disable weak_delegate

import UIKit

/// A CarouselSpot, a collection view based Spotable object that lays out its items in a horizontal order
open class CarouselSpot: NSObject, Gridable, SpotHorizontallyScrollable {

  public static var layout: Layout = .init()
  public static var interaction: Interaction = .init()

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// A boolean value that affects the sizing of items when using span, if enabled and the item count is less than the span, the CarouselSpot will even out the space between the items to align them
  open var dynamicSpan = false

  /// A Registry object that holds identifiers and classes for cells used in the CarouselSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the CarouselSpot
  open static var headers = Registry()

  /// A StateCache for the CarouselSpot
  open fileprivate(set) var stateCache: StateCache?

  /// A component struct used as configuration and data source for the CarouselSpot
  open var component: ComponentModel {
    didSet {
      configurePageControl()
    }
  }

  /// A configuration closure
  open var configure: ((ContentConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A CarouselScrollDelegate, used when a CarouselSpot scrolls
  open weak var carouselScrollDelegate: CarouselScrollDelegate?

  /// A SpotsDelegate that is used for the CarouselSpot
  open weak var delegate: SpotsDelegate?

  /// A UIPageControl, enable by setting pageIndicator to true
  open lazy var pageControl = UIPageControl()

  /// A custom UICollectionViewFlowLayout
  open var layout: CollectionLayout

  /// A UICollectionView, used as the main UI component for a CarouselSpot
  open var collectionView: UICollectionView

  /// The collection views background view
  open lazy var backgroundView = UIView()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// Initialize an instantiate of CarouselSpot
  ///
  /// - parameter component: A component
  /// - parameter collectionView: The collection view that the carousel should use for rendering
  /// - parameter layout: The object that the carousel should use for item layout
  ///
  /// - returns: An initialized carousel spot.
  ///
  /// In case you want to use a default collection view & layout, use `init(component:)`.
  public init(component: ComponentModel, collectionView: UICollectionView, layout: CollectionLayout) {
    self.component = component

    if self.component.layout == nil {
      self.component.layout = type(of: self).layout
    }

    self.component.interaction.scrollDirection = .horizontal

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true
    collectionView.alwaysBounceVertical = false
    collectionView.clipsToBounds = false

    self.collectionView = collectionView
    self.layout = layout

    super.init()
    self.userInterface = collectionView
    self.component.layout?.configure(spot: self)
    self.dynamicSpan = self.component.layout?.dynamicSpan ?? false
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = ComponentModel.Kind.carousel.string
    }

    registerDefault(view: CarouselSpotCell.self)
    registerComposite(view: CarouselComposite.self)
    registerDefaultHeader(header: CarouselSpotHeader.self)
    register()
    configureCollectionView()
  }

  /// Convenience initializer that creates an instance with a component
  ///
  /// - parameter component: The component model that the carousel should render
  public required convenience init(component: ComponentModel) {
    let layout = GridableLayout()
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    self.init(component: component, collectionView: collectionView, layout: layout)
  }

  /// A convenience initializer for CarouselSpot with base configuration.
  ///
  /// - parameter component:   A ComponentModel.
  /// - parameter top:         Top section inset.
  /// - parameter left:        Left section inset.
  /// - parameter bottom:      Bottom section inset.
  /// - parameter right:       Right section inset.
  /// - parameter itemSpacing: The item spacing used in the flow layout.
  /// - parameter lineSpacing: The line spacing used in the flow layout.
  ///
  /// - returns: An initialized carousel spot with configured layout.
  public convenience init(_ component: ComponentModel, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /// Instantiate a CarouselSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object.
  ///
  /// - returns: An initialized carousel spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(component: ComponentModel(stateCache.load()))
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
    collectionView.backgroundView = backgroundView
    #if os(iOS)
      collectionView.isPagingEnabled = component.interaction.paginate == .page
    #endif
  }

  /// Setup Spotable component with base size
  ///
  /// - parameter size: The size of the superview
  open func setup(_ size: CGSize) {
    collectionView.frame.size = size
    prepareItems()
    configurePageControl()

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = component.items.sorted(by: {
        $0.size.height > $1.size.height
      }).first?.size.height ?? 0

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    if !component.header.isEmpty {
      let resolve = type(of: self).headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.frame.size.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    if let componentLayout = component.layout {
      collectionView.frame.size.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }

    if let pageIndicatorPlacement = component.layout?.pageIndicatorPlacement {
      switch pageIndicatorPlacement {
      case .below:
        layout.sectionInset.bottom += pageControl.frame.height
        pageControl.frame.origin.y = collectionView.frame.height
      case .overlay:
        let verticalAdjustment = CGFloat(2)
        pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height - verticalAdjustment
      }
    }
  }

  private func configurePageControl() {
    guard let placement = component.layout?.pageIndicatorPlacement else {
      pageControl.removeFromSuperview()
      return
    }

    pageControl.numberOfPages = component.items.count
    pageControl.frame.origin.x = 0
    pageControl.frame.size.height = 22

    switch placement {
    case .below:
      pageControl.frame.size.width = backgroundView.frame.width
      pageControl.pageIndicatorTintColor = .lightGray
      pageControl.currentPageIndicatorTintColor = .gray
      backgroundView.addSubview(pageControl)
    case .overlay:
      pageControl.frame.size.width = collectionView.frame.width
      pageControl.pageIndicatorTintColor = nil
      pageControl.currentPageIndicatorTintColor = nil
      collectionView.addSubview(pageControl)
    }
  }
}
