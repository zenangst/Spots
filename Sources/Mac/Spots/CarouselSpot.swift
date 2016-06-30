import Cocoa
import Sugar
import Brick
import Hue

public class CarouselSpot: NSObject, Gridable {

  public struct Key {
    static let minimumInteritemSpacing = "itemSpacing"
    static let minimumLineSpacing = "lineSpacing"
    static let titleLeftMargin = "titleLeftMargin"
    static let titleFontSize = "titleFontSize"
    static let titleTextColor = "titleTextColor"
  }

  public struct Default {
    public static var titleFontSize: CGFloat = 18.0
    public static var titleTextColor: String = "999"
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
    public static var minimumInteritemSpacing: CGFloat = 0.0
    public static var minimumLineSpacing: CGFloat = 0.0
  }

  public static var views = ViewRegistry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: View.Type = NSView.self
  public static var defaultKind: StringConvertible = "carousel"

  public weak var spotsDelegate: SpotsDelegate?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0

  public private(set) var stateCache: SpotCache?

  public var gradientLayer: CAGradientLayer?

  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)
  public var adapter: SpotAdapter? {
    return collectionAdapter
  }

  public var layout: NSCollectionViewFlowLayout

  public lazy var titleView: NSTextField = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.grayColor()
    $0.drawsBackground = false
    $0.font = NSFont.systemFontOfSize(32)
  }

  public lazy var scrollView: ScrollView = ScrollView()
  public lazy var collectionView: NSCollectionView = NSCollectionView().then {
    $0.selectable = true
    $0.backgroundColors = [NSColor.clearColor()]

    let view = NSView()
    $0.backgroundView = view
  }

  public required init(component: Component) {
    self.component = component

    if component.meta("defaultFlow", type: Bool.self) == true {
      layout = NSCollectionViewFlowLayout()
    } else {
      layout = GridSpotLayout()
    }

    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .Horizontal

    super.init()

    setupCollectionView()
    configureLayout(component)
    scrollView.addSubview(titleView)
    scrollView.documentView = collectionView

    if component.title.isPresent {
      titleView.stringValue = component.title
      titleView.sizeToFit()
      layout.sectionInset.top += titleView.frame.size.height
    }
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
        component.items[$0.index].size.width = size.width / component.span
      }
    }

    if let gradientColor1 = component.meta("gradientColor1", type: String.self),
      gradientColor2 = component.meta("gradientColor2", type: String.self)
      where gradientLayer == nil {
      gradientLayer = CAGradientLayer()
      gradientLayer?.colors = [
        NSColor.hex(gradientColor1).CGColor,
        NSColor.hex(gradientColor2).CGColor
      ]
      gradientLayer?.locations = [0.0, 0.9]
      collectionView.backgroundView?.layer?.insertSublayer(gradientLayer!, atIndex: 0)
      gradientLayer?.frame.size.width = 3000
    }

    gradientLayer?.frame.size.height = size.height + layout.sectionInset.top + layout.sectionInset.bottom
    scrollView.frame.size.height = size.height + layout.sectionInset.top + layout.sectionInset.bottom

    var additionalX = collectionView.frame.width - layout.collectionViewContentSize.width
    if additionalX > 0.0 {
      additionalX = additionalX / 2
    } else {
      additionalX = 0
    }

    if component.title.isPresent {
      let fontSize = collectionView.frame.size.height / 20
      titleView.stringValue = component.title
      titleView.font = NSFont.systemFontOfSize(fontSize)
      titleView.sizeToFit()
    }

    titleView.frame.origin.x = additionalX + layout.sectionInset.left
    titleView.frame.origin.y = layout.sectionInset.top / 2 - titleView.frame.size.height / 2
    CarouselSpot.configure?(view: collectionView)

    layout.invalidateLayout()
  }
}

extension CarouselSpot {

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    var width = component.span > 0
      ? collectionView.frame.width / CGFloat(component.span)
      : collectionView.frame.width

    if let layout = layout as? NSCollectionViewFlowLayout {
      width -= layout.sectionInset.left - layout.sectionInset.right
      width -= layout.minimumInteritemSpacing
      width -= layout.minimumLineSpacing
    }

    if component.items[indexPath.item].size.width == 0.0 {
      component.items[indexPath.item].size.width = width
    }

    return CGSize(
      width: ceil(component.items[indexPath.item].size.width),
      height: ceil(component.items[indexPath.item].size.height))
  }
}
