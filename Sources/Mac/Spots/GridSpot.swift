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
  public static var defaultKind: StringConvertible = "grid"

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

  public var layout: NSCollectionViewFlowLayout

  public lazy var titleView: NSTextField = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.grayColor()
    $0.drawsBackground = false
    $0.font = NSFont.systemFontOfSize(32)
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

    if component.meta("defaultFlow", type: Bool.self) == true {
      layout = NSCollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
        $0.scrollDirection = .Vertical
      }
    } else {
      layout = GridSpotLayout().then {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
        $0.scrollDirection = .Vertical
      }
    }

    super.init()
    setupCollectionView()
    configureLayout(component)
    scrollView.addSubview(titleView)
    scrollView.contentView.addSubview(collectionView)

    if component.title.isPresent {
      titleView.stringValue = component.title
      titleView.sizeToFit()
      layout.sectionInset.top += titleView.frame.size.height
    }
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
    prepare()
  }

  public func setupCollectionView() {
    collectionView.delegate = collectionAdapter
    collectionView.dataSource = collectionAdapter
    collectionView.collectionViewLayout = layout
  }

  public func render() -> ScrollView {
    return scrollView
  }

  public func layout(size: CGSize) { }

  public func setup(size: CGSize) {
    if component.span > 0 {
      component.items.enumerate().forEach {
        component.items[$0.index].size.width = size.width
      }
    }

    scrollView.frame.size = layout.collectionViewContentSize
    collectionView.frame.size = layout.collectionViewContentSize

    GridSpot.configure?(view: collectionView)

    if component.title.isPresent {
      let fontSize = component.meta("titleFontSize", collectionView.frame.size.height / 20)
      titleView.stringValue = component.title
      titleView.font = NSFont.systemFontOfSize(fontSize)
      titleView.sizeToFit()
    }

    var additionalX = collectionView.frame.width - layout.collectionViewContentSize.width
    if additionalX > 0.0 {
      additionalX = additionalX / 2
    } else {
      additionalX = 0
    }

    titleView.frame.origin.x = additionalX + layout.sectionInset.left
    titleView.frame.origin.x = component.meta("titleLeftMargin", titleView.frame.origin.x)
    titleView.frame.origin.y = layout.sectionInset.top / 2 - titleView.frame.size.height / 2

    layout.invalidateLayout()
  }
}
