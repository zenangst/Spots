import Cocoa
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

  public enum LayoutType: String {
    case Grid = "grid"
    case Left = "left"
    case Flow = "flow"
  }

  public struct Key {
    public static let minimumInteritemSpacing = "itemSpacing"
    public static let minimumLineSpacing = "lineSpacing"
    public static let titleLeftMargin = "titleLeftMargin"
    public static let titleFontSize = "titleFontSize"
    public static let layout = "layout"
    public static let gridLayoutMaximumItemWidth = "itemWidthMax"
    public static let gridLayoutMaximumItemHeight = "itemHeightMax"
    public static let gridLayoutMinimumItemWidth = "itemMinWidth"
    public static let gridLayoutMinimumItemHeight = "itemMinHeight"
  }

  public struct Default {

    public struct Flow {
      public static var minimumInteritemSpacing: CGFloat = 0.0
      public static var minimumLineSpacing: CGFloat = 0.0
    }

    public static var titleFontSize: CGFloat = 18.0
    public static var titleLeftInset: CGFloat = 0.0
    public static var titleTopInset: CGFloat = 10.0
    public static var defaultLayout: String = LayoutType.Flow.rawValue
    public static var gridLayoutMaximumItemWidth = 120
    public static var gridLayoutMaximumItemHeight = 120
    public static var gridLayoutMinimumItemWidth = 80
    public static var gridLayoutMinimumItemHeight = 80
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
  }

  public static var views = Registry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: View.Type = NSView.self
  public static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self
  public static var defaultKind: StringConvertible = LayoutType.Grid.rawValue

  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0

  public private(set) var stateCache: SpotCache?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }

  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  public var layout: NSCollectionViewLayout

  public lazy var titleView: NSTextField = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.grayColor()
    $0.drawsBackground = false
  }

  public lazy var scrollView: ScrollView = ScrollView().then {
    let view = NSView()
    $0.documentView = view
  }

  public lazy var collectionView: NSCollectionView = NSCollectionView().then {
    $0.backgroundColors = [NSColor.clearColor()]
    $0.selectable = true
    $0.allowsMultipleSelection = false
    $0.allowsEmptySelection = true
    $0.layer = CALayer()
    $0.wantsLayer = true
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.2).CGColor
  }

  public required init(component: Component) {
    self.component = component
    self.layout = GridSpot.setupLayout(component)
    super.init()
    registerAndPrepare()
    setupCollectionView()
    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.contentView.addSubview(collectionView)

    if let layout = layout as? NSCollectionViewFlowLayout where component.title.isPresent {
      configureTitleView(layout.sectionInset)
    }
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    collectionView.delegate = nil
    collectionView.dataSource = nil
  }

  private static func configureLayoutInsets(component: Component, layout: NSCollectionViewFlowLayout) -> NSCollectionViewFlowLayout {
    layout.sectionInset = NSEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))

    layout.minimumInteritemSpacing = component.meta(GridSpot.Key.minimumInteritemSpacing, Default.Flow.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridSpot.Key.minimumLineSpacing, Default.Flow.minimumLineSpacing)

    return layout
  }

  private static func setupLayout(component: Component) -> NSCollectionViewLayout {
    let layout: NSCollectionViewLayout

    switch LayoutType(rawValue: component.meta(Key.layout, Default.defaultLayout)) ?? LayoutType.Flow {
    case .Grid:
      let gridLayout = NSCollectionViewGridLayout()

      gridLayout.maximumItemSize = CGSize(width: component.meta(Key.gridLayoutMaximumItemWidth, Default.gridLayoutMaximumItemWidth),
                                          height: component.meta(Key.gridLayoutMaximumItemHeight, Default.gridLayoutMaximumItemHeight))
      gridLayout.minimumItemSize = CGSize(width: component.meta(Key.gridLayoutMinimumItemWidth, Default.gridLayoutMinimumItemWidth),
                                          height: component.meta(Key.gridLayoutMinimumItemHeight, Default.gridLayoutMinimumItemHeight))
      layout = gridLayout
    case .Left:
      let leftLayout = CollectionViewLeftLayout()
      configureLayoutInsets(component, layout: leftLayout)
      layout = leftLayout

    case .Flow:
      fallthrough
    default:
      let flowLayout = NSCollectionViewFlowLayout()
      configureLayoutInsets(component, layout: flowLayout)
      flowLayout.scrollDirection = .Vertical
      layout = flowLayout
    }

    return layout
  }

  public func setupCollectionView() {
    collectionView.delegate = collectionAdapter
    collectionView.dataSource = collectionAdapter
    collectionView.collectionViewLayout = layout
  }

  public func render() -> ScrollView {
    return scrollView
  }

  public func layout(size: CGSize) {
    layout.prepareForTransitionToLayout(layout)

    var layoutInsets = NSEdgeInsets()
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

    GridSpot.configure?(view: collectionView)

    if component.title.isPresent {
      configureTitleView(layoutInsets)
    }
  }

  public func setup(size: CGSize) {
    var size = size
    size.height = layout.collectionViewContentSize.height
    layout(size)
  }

  private func configureTitleView(layoutInsets: NSEdgeInsets) {
    titleView.stringValue = component.title
    titleView.font = NSFont.systemFontOfSize(component.meta(Key.titleFontSize, Default.titleFontSize))
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
