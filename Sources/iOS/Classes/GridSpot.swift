import UIKit
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

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

  public static var views: Registry = Registry()
  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?
  public static var headers = Registry()

  public var component: Component
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }

  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)
  public lazy var layout: CollectionLayout = CollectionLayout()
  public private(set) var stateCache: SpotCache?
  /// Indicator to calculate the height based on content
  public var useDynamicHeight = true

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
    $0.dataSource = self.collectionAdapter
    $0.delegate = self.collectionAdapter
    $0.scrollEnabled = false
  }

  public required init(component: Component) {
    self.component = component
    super.init()

    self.configureLayout()

    if GridSpot.views.defaultItem == nil {
      GridSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    }

    if GridSpot.views.composite == nil {
      GridSpot.views.composite =  Registry.Item.classType(GridComposite.self)
    }
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? "grid"))
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /**
   Configure section insets and layout spacing for the UICollectionViewFlow using component meta data
   */
  func configureLayout() {
    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(GridableMeta.Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridableMeta.Key.minimumLineSpacing, Default.minimumLineSpacing)
  }
}
