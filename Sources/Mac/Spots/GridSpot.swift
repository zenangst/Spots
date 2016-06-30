import Cocoa
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

  public enum LayoutType: String {
    case Grid
    case Left
    case Flow

    var string: String {
      return rawValue.lowercaseString
    }
  }

  public struct Key {
    static let minimumInteritemSpacing = "itemSpacing"
    static let minimumLineSpacing = "lineSpacing"
    static let titleLeftMargin = "titleLeftMargin"
    static let titleFontSize = "titleFontSize"
    static let layout = LayoutType.Flow.rawValue
    static let gridLayoutMaximumItemWidth = "itemWidthMax"
    static let gridLayoutMaximumItemHeight = "itemHeightMax"
    static let gridLayoutMinimumItemWidth = "itemMinWidth"
    static let gridLayoutMinimumItemHeight = "itemMinHeight"
  }

  public struct Default {

    public struct Flow {
      public static var minimumInteritemSpacing: CGFloat = 0.0
      public static var minimumLineSpacing: CGFloat = 0.0
    }

    public static var titleFontSize: CGFloat = 18.0
    public static var defaultLayout: LayoutType = .Flow
    public static var gridLayoutMaximumItemWidth = 120
    public static var gridLayoutMaximumItemHeight = 120
    public static var gridLayoutMinimumItemWidth = 80
    public static var gridLayoutMinimumItemHeight = 80
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
  }

  public static var views = ViewRegistry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: View.Type = NSView.self
  public static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self
  public static var defaultKind: StringConvertible = LayoutType.Grid.string

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
    view.autoresizingMask = .ViewWidthSizable
    view.autoresizesSubviews = true
    $0.documentView = view
  }

  public lazy var collectionView: NSCollectionView = NSCollectionView().then {
    $0.backgroundColors = [NSColor.clearColor()]
    $0.selectable = true
    $0.autoresizingMask = .ViewWidthSizable
    $0.autoresizesSubviews = true
    $0.layer = CALayer()
    $0.wantsLayer = true
  }

  public required init(component: Component) {
    self.component = component
    self.layout = GridSpot.setupLayout(component)
    super.init()
    setupCollectionView()
    scrollView.addSubview(titleView)
    scrollView.contentView.addSubview(collectionView)

    if component.title.isPresent {
      titleView.stringValue = component.title
      titleView.sizeToFit()

      let top = titleView.frame.size.height / 2
      (layout as? NSCollectionViewFlowLayout)?.sectionInset.top += top
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

  private static func configureLayoutInsets(component: Component, layout: NSCollectionViewFlowLayout) -> NSCollectionViewFlowLayout {
    layout.sectionInset = NSEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))

    layout.minimumInteritemSpacing = Default.Flow.minimumInteritemSpacing
    layout.minimumLineSpacing = Default.Flow.minimumLineSpacing

    return layout
  }

  private static func setupLayout(component: Component) -> NSCollectionViewLayout {
    let layout: NSCollectionViewLayout

    switch component.meta(Key.layout, Default.defaultLayout) {
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

    var layoutInsets = NSEdgeInsets()
    if let layout = layout as? NSCollectionViewFlowLayout {
      layoutInsets = layout.sectionInset
    }

    scrollView.frame.size.width = size.width - layoutInsets.right
    scrollView.frame.size.height = layout.collectionViewContentSize.height + layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.height = scrollView.frame.size.height - layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.width = size.width - layoutInsets.right

    GridSpot.configure?(view: collectionView)

    if component.title.isPresent {
      titleView.stringValue = component.title
      titleView.font = NSFont.systemFontOfSize(component.meta(Key.titleFontSize, Default.titleFontSize))
      titleView.sizeToFit()
    }


    titleView.frame.origin.x = layoutInsets.left
    titleView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = layoutInsets.top - titleView.frame.size.height / 2

    layout.invalidateLayout()
  }

  public func setup(size: CGSize) {
    layout(size)
    prepare()

    layout.invalidateLayout()
  }
}
