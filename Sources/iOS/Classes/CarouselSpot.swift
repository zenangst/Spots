import UIKit
import Sugar
import Brick

public class CarouselSpot: NSObject, Gridable {

  public struct Key {
    public static let minimumInteritemSpacing = "item-spacing"
    public static let minimumLineSpacing = "line-spacing"
  }

  public struct Default {
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
    public static var minimumInteritemSpacing: CGFloat = 0.0
    public static var minimumLineSpacing: CGFloat = 0.0
  }

  public static var views: Registry = Registry().then {
    $0.defaultItem = Registry.Item.classType(CarouselSpotCell.self)
    $0.composite =  Registry.Item.classType(CarouselComposite.self)
  }

  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?

  public static var headers = Registry().then {
    $0.defaultItem = Registry.Item.classType(CarouselSpotHeader.self)
  }

  public private(set) var stateCache: SpotCache?

  public var component: Component {
    willSet(value) {
      #if os(iOS)
        if component.items.count > 1 && component.span > 0 {
          pageControl.numberOfPages = Int(floor(CGFloat(component.items.count) / component.span))
        }
      #endif
    }
  }

  #if os(iOS)
  public var paginate = false {
    willSet(newValue) {
      if component.span == 1 {
        collectionView.pagingEnabled = newValue
      }
    }
  }

  public var paginateByItem: Bool = false
  #endif

  public var pageIndicator: Bool = false {
    willSet(value) {
      if value {
        pageControl.width = backgroundView.frame.width
        collectionView.backgroundView?.addSubview(pageControl)
      } else {
        pageControl.removeFromSuperview()
      }
    }
  }

  public var configure: (SpotConfigurable -> Void)?

  public weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?
  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }
  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  public lazy var pageControl = UIPageControl().then {
    $0.frame.size.height = 22
    $0.pageIndicatorTintColor = UIColor.lightGrayColor()
    $0.currentPageIndicatorTintColor = UIColor.grayColor()
  }

  public lazy var layout: CollectionLayout = GridableLayout().then {
    $0.scrollDirection = .Horizontal
  }

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
    $0.dataSource = self.collectionAdapter
    $0.delegate = self.collectionAdapter
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundView = self.backgroundView
  }

  public lazy var backgroundView = UIView()

  public required init(component: Component) {
    self.component = component
    super.init()
    configureInsets()
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  public func setup(size: CGSize) {
    collectionView.frame.size = size

    if collectionView.contentSize.height > 0 {
      collectionView.height = collectionView.contentSize.height
    } else {
      collectionView.height = component.items.sort({ $0.size.height > $1.size.height }).first?.size.height ?? 0

      if collectionView.height > 0 {
        collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    #if os(iOS)
    paginate ?= component.meta("paginate", type: Bool.self)
    pageIndicator ?= component.meta("pageIndicator", type: Bool.self)
    #endif

    if !component.header.isEmpty {
      let resolve = self.dynamicType.headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(view: collectionView, layout: layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    guard pageIndicator else { return }
    layout.sectionInset.bottom = layout.sectionInset.bottom + pageControl.height
    collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
    pageControl.frame.origin.y = collectionView.height - pageControl.height
  }

  func configureInsets() {
    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(Key.minimumLineSpacing, Default.minimumLineSpacing)
  }
}
