import Cocoa
import Brick

open class CarouselSpot: NSObject, Gridable {

  public struct Key {
    public static let minimumInteritemSpacing = "item-spacing"
    public static let minimumLineSpacing = "line-spacing"
    public static let titleFontSize = "title-font-size"
    public static let titleLeftMargin = "title-left-margin"
    public static let titleTopInset = "title-top-inset"
    public static let titleBottomInset = "title-bottom-inset"
    public static let titleLeftInset = "title-left-inset"
    public static let titleTextColor = "title-text-color"
  }

  public struct Default {
    public static var titleFontSize: Double = 18.0
    public static var titleLeftInset: Double = 0.0
    public static var titleTopInset: Double = 10.0
    public static var titleBottomInset: Double = 10.0
    public static var titleTextColor: String = "000000"
    public static var sectionInsetTop: Double = 0.0
    public static var sectionInsetLeft: Double = 0.0
    public static var sectionInsetRight: Double = 0.0
    public static var sectionInsetBottom: Double = 0.0
    public static var minimumInteritemSpacing: Double = 0.0
    public static var minimumLineSpacing: Double = 0.0
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()
  open static var grids = GridRegistry()
  open static var configure: ((_ view: NSCollectionView) -> Void)?
  open static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self
  open static var defaultView: View.Type = NSView.self
  open static var defaultKind: StringConvertible = Component.Kind.Carousel.string

  open weak var delegate: SpotsDelegate?

  open var cachedViews = [String : SpotConfigurable]()
  open var component: Component
  open var configure: ((SpotConfigurable) -> Void)?
  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  open fileprivate(set) var stateCache: SpotCache?

  open var gradientLayer: CAGradientLayer?

  open lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)
  open var adapter: SpotAdapter? {
    return collectionAdapter
  }

  open lazy var layout: NSCollectionViewLayout = NSCollectionViewFlowLayout()

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.drawsBackground = false
    titleView.textColor = NSColor.gray

    return titleView
  }()

  open lazy var scrollView: ScrollView = ScrollView()

  open lazy var collectionView: NSCollectionView = {
    let collectionView = NSCollectionView()
    collectionView.isSelectable = true
    collectionView.backgroundColors = [NSColor.clear]

    let view = NSView()
    collectionView.backgroundView = view

    return collectionView
  }()

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    return lineView
  }()

  public required init(component: Component) {
    self.component = component

    super.init()

    registerAndPrepare()
    setupCollectionView()
    configureLayoutInsets(component)

    if let layout = layout as? NSCollectionViewFlowLayout, !component.title.isEmpty {
      configureTitleView(layout.sectionInset)
    }
    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.documentView = collectionView
  }

  fileprivate func configureLayoutInsets(_ component: Component) {
    guard let layout = layout as? NSCollectionViewFlowLayout else { return }

    layout.sectionInset = EdgeInsets(
      top: CGFloat(component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop)),
      left: CGFloat(component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft)),
      bottom: CGFloat(component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom)),
      right: CGFloat(component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight)))
    layout.minimumInteritemSpacing = CGFloat(component.meta(Key.minimumInteritemSpacing, Default.minimumInteritemSpacing))
    layout.minimumLineSpacing = CGFloat(component.meta(Key.minimumLineSpacing, Default.minimumLineSpacing))
    layout.scrollDirection = .horizontal
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  deinit {
    collectionView.delegate = nil
    collectionView.dataSource = nil
  }

  open func setupCollectionView() {
    collectionView.delegate = collectionAdapter
    collectionView.dataSource = collectionAdapter
    collectionView.collectionViewLayout = layout
  }

  open func render() -> ScrollView {
    return scrollView
  }

  open func layout(_ size: CGSize) {
    var layoutInsets = EdgeInsets()

    if let layout = layout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = CGFloat(component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop)) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    scrollView.frame.size.height = (component.items.first?.size.height ?? layoutInsets.top) + layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.height = scrollView.frame.size.height
    gradientLayer?.frame.size.height = scrollView.frame.size.height

    if !component.title.isEmpty {
      configureTitleView(layoutInsets)
    }

    if component.span > 0 {
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
    }

    if component.span == 1 && component.items.count == 1 {
      scrollView.scrollingEnabled = (component.items.count > 1)
      scrollView.hasHorizontalScroller = (component.items.count > 1)
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
      layout.invalidateLayout()
    }
  }

  open func setup(_ size: CGSize) {
    if component.span > 0 {
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
    }

    layout(size)
    CarouselSpot.configure?(collectionView)
  }

  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    titleView.stringValue = component.title
    titleView.sizeToFit()
    titleView.font = NSFont.systemFont(ofSize: CGFloat(component.meta(Key.titleFontSize, Default.titleFontSize)))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (component.meta(Key.titleLeftMargin, titleView.frame.origin.x) * 2)
    lineView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.x = collectionView.frame.origin.x + CGFloat(component.meta(Key.titleLeftInset, Default.titleLeftInset))
    titleView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = CGFloat(component.meta(Key.titleTopInset, Default.titleTopInset)) - CGFloat(component.meta(Key.titleBottomInset, Default.titleBottomInset))
    lineView.frame.origin.y = titleView.frame.maxY + 5
    collectionView.frame.size.height = scrollView.frame.size.height + titleView.frame.size.height
  }
}
