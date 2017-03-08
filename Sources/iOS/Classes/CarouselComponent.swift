// swiftlint:disable weak_delegate

import UIKit

/// A CarouselComponent, a collection view based CoreComponent object that lays out its items in a horizontal order
open class CarouselComponent: NSObject, Gridable, ComponentHorizontallyScrollable {

  public static var layout: Layout = .init()
  public static var interaction: Interaction = .init()

  /// Child components
  public var compositeComponents: [CompositeComponent] = []

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: ComponentFocusDelegate?

  /// A boolean value that affects the sizing of items when using span, if enabled and the item count is less than the span, the CarouselComponent will even out the space between the items to align them
  open var dynamicSpan = false

  /// A Registry object that holds identifiers and classes for cells used in the CarouselComponent
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the CarouselComponent
  open static var headers = Registry()

  /// A StateCache for the CarouselComponent
  open fileprivate(set) var stateCache: StateCache?

  /// A component struct used as configuration and data source for the CarouselComponent
  open var model: ComponentModel {
    didSet {
      configurePageControl()
    }
  }

  /// A configuration closure
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A CarouselScrollDelegate, used when a CarouselComponent scrolls
  open weak var carouselScrollDelegate: CarouselScrollDelegate?

  /// A ComponentDelegate that is used for the CarouselComponent
  open weak var delegate: ComponentDelegate?

  /// A UIPageControl, enable by setting pageIndicator to true
  open lazy var pageControl = UIPageControl()

  /// A custom UICollectionViewFlowLayout
  open var layout: CollectionLayout

  /// A UICollectionView, used as the main UI component for a CarouselComponent
  open var collectionView: UICollectionView

  /// The collection views background view
  open lazy var backgroundView = UIView()

  public var userInterface: UserInterface?
  var componentDataSource: DataSource?
  var componentDelegate: Delegate?

  /// Initialize an instantiate of CarouselComponent
  ///
  /// - parameter component: A component
  /// - parameter collectionView: The collection view that the carousel should use for rendering
  /// - parameter layout: The object that the carousel should use for item layout
  ///
  /// - returns: An initialized carousel spot.
  ///
  /// In case you want to use a default collection view & layout, use `init(component:)`.
  public init(model: ComponentModel, collectionView: UICollectionView, layout: CollectionLayout) {
    self.model = model

    if self.model.layout == nil {
      self.model.layout = type(of: self).layout
    }

    self.model.interaction.scrollDirection = .horizontal

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true
    collectionView.alwaysBounceVertical = false
    collectionView.clipsToBounds = false

    self.collectionView = collectionView
    self.layout = layout

    super.init()
    self.userInterface = collectionView
    self.model.layout?.configure(component: self)
    self.dynamicSpan = self.model.layout?.dynamicSpan ?? false
    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)

    if model.kind.isEmpty {
      self.model.kind = ComponentModel.Kind.carousel.string
    }

    registerDefault(view: CarouselComponentCell.self)
    registerComposite(view: CarouselComposite.self)
    registerDefaultHeader(header: CarouselComponentHeader.self)
    register()
    configureCollectionView()
  }

  /// Convenience initializer that creates an instance with a component
  ///
  /// - parameter component: The component model that the carousel should render
  public required convenience init(model: ComponentModel) {
    let layout = GridableLayout()
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    self.init(model: model, collectionView: collectionView, layout: layout)
  }

  /// A convenience initializer for CarouselComponent with base configuration.
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
  public convenience init(_ model: ComponentModel, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(model: model)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /// Instantiate a CarouselComponent with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the CoreComponent object.
  ///
  /// - returns: An initialized carousel spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    componentDataSource = nil
    componentDelegate = nil
    userInterface = nil
  }

  /// Configure collection view with data source, delegate and background view
  public func configureCollectionView() {
    register()
    collectionView.dataSource = componentDataSource
    collectionView.delegate = componentDelegate
    collectionView.backgroundView = backgroundView
    #if os(iOS)
      collectionView.isPagingEnabled = model.interaction.paginate == .page
    #endif
  }

  /// Setup CoreComponent component with base size
  ///
  /// - parameter size: The size of the superview
  open func setup(_ size: CGSize) {
    collectionView.frame.size = size
    prepareItems()
    configurePageControl()

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = model.items.sorted(by: {
        $0.size.height > $1.size.height
      }).first?.size.height ?? 0

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    if !model.header.isEmpty {
      let resolve = type(of: self).headers.make(model.header)
      layout.headerReferenceSize.width = collectionView.frame.size.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselComponent.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    if let componentLayout = model.layout {
      collectionView.frame.size.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }

    if let pageIndicatorPlacement = model.layout?.pageIndicatorPlacement {
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
    guard let placement = model.layout?.pageIndicatorPlacement else {
      pageControl.removeFromSuperview()
      return
    }

    pageControl.numberOfPages = model.items.count
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
