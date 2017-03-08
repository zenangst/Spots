// swiftlint:disable weak_delegate

import Cocoa

open class GridComponent: NSObject, Gridable {

  /// Return collection view as a scroll view
  open var view: ScrollView {
    return scrollView
  }

  public static var layout: Layout = Layout()

  /// Child components
  public var compositeComponents: [CompositeComponent] = []

  /// An enum layout type
  ///
  /// - Grid: Resolves to NSCollectionViewGridLayout
  /// - Left: Resolves to CollectionViewLeftLayout
  /// - Flow: Resolves to NSCollectionViewFlowLayout
  public enum LayoutType: String {
    case grid
    case left
    case flow
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

  open weak var delegate: ComponentDelegate?

  open var model: ComponentModel
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as ItemConfigurable in collectionView.visibleItems() {
        configure(cell)
      }
    }
  }

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
   A required initializer for creating a GridComponent

   - parameter component: A component struct
   */
  public required init(model: ComponentModel) {
    self.model = model

    if self.model.layout == nil {
      self.model.layout = type(of: self).layout
    }

    self.collectionView = CollectionView()
    self.layout = GridComponent.setupLayout(model)
    super.init()
    self.userInterface = collectionView
    self.model.layout?.configure(component: self)
    self.spotDataSource = DataSource(component: self)
    self.spotDelegate = Delegate(component: self)

    if model.kind.isEmpty {
      self.model.kind = ComponentModel.Kind.grid.string
    }

    registerDefault(view: GridComponentCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    setupCollectionView()
    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.contentView.addSubview(collectionView)

    if let layout = layout as? NSCollectionViewFlowLayout, !model.title.isEmpty {
      configureTitleView(layout.sectionInset)
    }
  }

  /**
   A convenience init for initializing a gridComponent

   - parameter cacheKey: A cache key
   */
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    collectionView.delegate = nil
    collectionView.dataSource = nil
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  /**
   A private method for configuring the layout for the collection view

   - parameter component: The component for the GridComponent

   - returns: A NSCollectionView layout determined by the ComponentModel
   */
  fileprivate static func setupLayout(_ model: ComponentModel) -> NSCollectionViewLayout {
    let layout: NSCollectionViewLayout

    switch LayoutType(rawValue: model.meta(Key.layout, Default.defaultLayout)) ?? LayoutType.flow {
    case .grid:
      let gridLayout = NSCollectionViewGridLayout()

      gridLayout.maximumItemSize = CGSize(width: model.meta(Key.gridLayoutMaximumItemWidth, Default.gridLayoutMaximumItemWidth),
                                          height: model.meta(Key.gridLayoutMaximumItemHeight, Default.gridLayoutMaximumItemHeight))
      gridLayout.minimumItemSize = CGSize(width: model.meta(Key.gridLayoutMinimumItemWidth, Default.gridLayoutMinimumItemWidth),
                                          height: model.meta(Key.gridLayoutMinimumItemHeight, Default.gridLayoutMinimumItemHeight))
      layout = gridLayout
    case .left:
      let leftLayout = CollectionViewLeftLayout()
      layout = leftLayout
    default:
      let flowLayout = NSCollectionViewFlowLayout()
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

  /**
   Layout with size

   - parameter size: A CGSize from the GridComponent superview
   */
  open func layout(_ size: CGSize) {
    layout.prepareForTransition(to: layout)
    var layoutInsets = EdgeInsets()
    if let layout = layout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = model.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    var layoutHeight = layout.collectionViewContentSize.height + layoutInsets.top + layoutInsets.bottom

    if model.items.isEmpty {
      layoutHeight = size.height + layoutInsets.top + layoutInsets.bottom
    }

    scrollView.frame.size.width = size.width - layoutInsets.right
    scrollView.frame.size.height = layoutHeight
    collectionView.frame.size.height = scrollView.frame.size.height - layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.width = size.width - layoutInsets.right

    if !model.title.isEmpty {
      configureTitleView(layoutInsets)
    }
  }

  /**
   Perform setup with size

   - parameter size: A CGSize from the GridComponent superview
   */
  open func setup(_ size: CGSize) {
    var size = size
    size.height = layout.collectionViewContentSize.height
    layout.invalidateLayout()
    layout(size)
    GridComponent.configure?(collectionView)
  }

  /**
   A private setup method for configuring the title view

   - parameter layoutInsets: EdgeInsets used to configure the title and line view size and origin
   */
  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    titleView.stringValue = model.title
    titleView.font = NSFont.systemFont(ofSize: model.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (model.meta(Key.titleLeftMargin, Default.titleLeftInset) * 2)
    lineView.frame.origin.x = model.meta(Key.titleLeftMargin, Default.titleLeftInset)
    titleView.frame.origin.x = layoutInsets.left
    titleView.frame.origin.x = model.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = titleView.frame.size.height / 2
    lineView.frame.origin.y = titleView.frame.maxY + 8
  }
}
