import Cocoa
import Brick

open class GridSpot: NSObject, Gridable {

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  /// An enum layout type
  ///
  /// - Grid: Resolves to NSCollectionViewGridLayout
  /// - Left: Resolves to CollectionViewLeftLayout
  /// - Flow: Resolves to NSCollectionViewFlowLayout
  public enum LayoutType: String {
    case grid = "grid"
    case left = "left"
    case flow = "flow"
  }

  public struct Key {
    /// The key for minimum interitem spacing
    public static let minimumInteritemSpacing = "item-spacing"
    /// The key for minimum line spacing
    public static let minimumLineSpacing = "line-spacing"
    /// The key for title left margin
    public static let titleLeftMargin = "title-left-margin"
    /// The key for title font size
    public static let titleFontSize = "title-font-size"
    /// The key for layout
    public static let layout = "layout"
    /// The key for grid layout maximum item width
    public static let gridLayoutMaximumItemWidth = "item-width-max"
    /// The key for grid layout maximum item height
    public static let gridLayoutMaximumItemHeight = "item-height-max"
    /// The key for grid layout minimum item width
    public static let gridLayoutMinimumItemWidth = "item-min-width"
    /// The key for grid layout minimum item height
    public static let gridLayoutMinimumItemHeight = "item-min-height"
  }

  public struct Default {

    public struct Flow {
      /// Default minimum interitem spacing
      public static var minimumInteritemSpacing: CGFloat = 0.0
      /// Default minimum line spacing
      public static var minimumLineSpacing: CGFloat = 0.0
    }

    /// Default title font size
    public static var titleFontSize: CGFloat = 18.0
    /// Default left inset of the title
    public static var titleLeftInset: CGFloat = 0.0
    /// Default top inset of the title
    public static var titleTopInset: CGFloat = 10.0
    /// Default layout
    public static var defaultLayout: String = LayoutType.flow.rawValue
    /// Default grid layout maximum item width
    public static var gridLayoutMaximumItemWidth = 120
    /// Default grid layout maximum item height
    public static var gridLayoutMaximumItemHeight = 120
    /// Default grid layout minimum item width
    public static var gridLayoutMinimumItemWidth = 80
    /// Default grid layout minimum item height
    public static var gridLayoutMinimumItemHeight = 80
    /// Default top section inset
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default left section inset
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default bottom section inset
    public static var sectionInsetBottom: CGFloat = 0.0
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()
  open static var grids = GridRegistry()
  open static var configure: ((_ view: NSCollectionView) -> Void)?
  open static var defaultView: View.Type = NSView.self
  open static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self
  open static var defaultKind: StringConvertible = LayoutType.grid.rawValue

  open weak var delegate: SpotsDelegate?

  open var component: Component
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in collectionView.visibleItems() {
        configure(cell)
      }
    }
  }
  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  open fileprivate(set) var stateCache: StateCache?

  open var layout: NSCollectionViewLayout

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.textColor = NSColor.gray
    titleView.drawsBackground = false

    return titleView
  }()

  open lazy var scrollView: ScrollView = {
    let scrollView = ScrollView()
    let view = NSView()
    scrollView.documentView = view

    return scrollView
  }()

  open var collectionView: CollectionView

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    return lineView
  }()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /**
   A required initializer for creating a GridSpot

   - parameter component: A component struct
   */
  public required init(component: Component) {
    self.component = component
    self.collectionView = CollectionView()
    self.layout = GridSpot.setupLayout(component)
    super.init()
    self.userInterface = collectionView
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = Component.Kind.Grid.string
    }

    registerDefault(view: GridSpotCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    setupCollectionView()
    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.contentView.addSubview(collectionView)

    if let layout = layout as? NSCollectionViewFlowLayout, !component.title.isEmpty {
      configureTitleView(layout.sectionInset)
    }
  }

  /**
   A convenience init for initializing a Gridspot with a title and a kind

   - parameter title: A string that is used as a title for the GridSpot
   - parameter kind:  An identifier to determine which kind should be set on the Component
   */
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }

  /**
   A convenience init for initializing a Gridspot

   - parameter cacheKey: A cache key
   */
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    collectionView.delegate = nil
    collectionView.dataSource = nil
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  @discardableResult fileprivate static func configureLayoutInsets(_ component: Component, layout: NSCollectionViewFlowLayout) -> NSCollectionViewFlowLayout {
    layout.sectionInset = EdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))

    layout.minimumInteritemSpacing = component.meta(GridSpot.Key.minimumInteritemSpacing, Default.Flow.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridSpot.Key.minimumLineSpacing, Default.Flow.minimumLineSpacing)

    return layout
  }

  /**
   A private method for configuring the layout for the collection view

   - parameter component: The component for the GridSpot

   - returns: A NSCollectionView layout determined by the Component
   */
  fileprivate static func setupLayout(_ component: Component) -> NSCollectionViewLayout {
    let layout: NSCollectionViewLayout

    switch LayoutType(rawValue: component.meta(Key.layout, Default.defaultLayout)) ?? LayoutType.flow {
    case .grid:
      let gridLayout = NSCollectionViewGridLayout()

      gridLayout.maximumItemSize = CGSize(width: component.meta(Key.gridLayoutMaximumItemWidth, Default.gridLayoutMaximumItemWidth),
                                          height: component.meta(Key.gridLayoutMaximumItemHeight, Default.gridLayoutMaximumItemHeight))
      gridLayout.minimumItemSize = CGSize(width: component.meta(Key.gridLayoutMinimumItemWidth, Default.gridLayoutMinimumItemWidth),
                                          height: component.meta(Key.gridLayoutMinimumItemHeight, Default.gridLayoutMinimumItemHeight))
      layout = gridLayout
    case .left:
      let leftLayout = CollectionViewLeftLayout()
      configureLayoutInsets(component, layout: leftLayout)
      layout = leftLayout
    default:
      let flowLayout = NSCollectionViewFlowLayout()
      configureLayoutInsets(component, layout: flowLayout)
      flowLayout.scrollDirection = .vertical
      layout = flowLayout
    }

    return layout
  }

  /**
   Configure delegate, data source and layout for collection view
   */
  open func setupCollectionView() {
    collectionView.backgroundColors = [NSColor.clear]
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    collectionView.allowsEmptySelection = true
    collectionView.layer = CALayer()
    collectionView.wantsLayer = true
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
    collectionView.collectionViewLayout = layout

    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    collectionView.backgroundView = backgroundView
  }

  /// Return collection view as a scroll view
  ///
  /// - returns: UIScrollView: Returns a UICollectionView as a UIScrollView
  ///
  open func render() -> ScrollView {
    return scrollView
  }

  /**
   Layout with size

   - parameter size: A CGSize from the GridSpot superview
   */
  open func layout(_ size: CGSize) {
    layout.prepareForTransition(to: layout)
    var layoutInsets = EdgeInsets()
    if let layout = layout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    var layoutHeight = layout.collectionViewContentSize.height + layoutInsets.top + layoutInsets.bottom

    if component.items.isEmpty {
      layoutHeight = size.height + layoutInsets.top + layoutInsets.bottom
    }

    scrollView.frame.size.width = size.width - layoutInsets.right
    scrollView.frame.size.height = layoutHeight
    collectionView.frame.size.height = scrollView.frame.size.height - layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.width = size.width - layoutInsets.right

    if !component.title.isEmpty {
      configureTitleView(layoutInsets)
    }
  }

  /**
   Perform setup with size

   - parameter size: A CGSize from the GridSpot superview
   */
  open func setup(_ size: CGSize) {
    var size = size
    size.height = layout.collectionViewContentSize.height
    layout.invalidateLayout()
    layout(size)
    GridSpot.configure?(collectionView)
  }

  /**
   A private setup method for configuring the title view

   - parameter layoutInsets: EdgeInsets used to configure the title and line view size and origin
   */
  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    titleView.stringValue = component.title
    titleView.font = NSFont.systemFont(ofSize: component.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (component.meta(Key.titleLeftMargin, Default.titleLeftInset) * 2)
    lineView.frame.origin.x = component.meta(Key.titleLeftMargin, Default.titleLeftInset)
    titleView.frame.origin.x = layoutInsets.left
    titleView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = titleView.frame.size.height / 2
    lineView.frame.origin.y = titleView.frame.maxY + 8
  }
}
