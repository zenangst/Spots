import Cocoa
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

  public static var views = ViewRegistry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: RegularView.Type = NSView.self
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

  public lazy var layout: NSCollectionViewFlowLayout = NSCollectionViewFlowLayout().then {
    $0.minimumInteritemSpacing = 0
    $0.minimumLineSpacing = 0
    $0.scrollDirection = .Vertical
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
    super.init()
    setupCollectionView()
//    scrollView.documentView = collectionView
    scrollView.contentView.addSubview(collectionView)
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

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
//      if let layout = layout as? LeftFlowLayout {
//        layout.minimumInteritemSpacing = itemSpacing
//        layout.minimumLineSpacing = lineSpacing
//      }
  }

  public func setupCollectionView() {
//    collectionView.maxNumberOfColumns = Int(component.span)
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
    layout.invalidateLayout()
  }
}
