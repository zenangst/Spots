import UIKit
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

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
    public static var gridLayoutMaximumItemWidth = 120
    public static var gridLayoutMaximumItemHeight = 120
    public static var gridLayoutMinimumItemWidth = 80
    public static var gridLayoutMinimumItemHeight = 80
    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
  }

  public static var views: Registry = Registry().then {
    $0.defaultItem = Registry.Item.classType(GridSpotCell.self)
  }

  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?

  public static var headers = Registry()

  public var component: Component
  public var index = 0
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }

  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)
  public lazy var layout = UICollectionViewFlowLayout()
  public private(set) var stateCache: SpotCache?

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
    $0.dataSource = self.collectionAdapter
    $0.delegate = self.collectionAdapter
    $0.scrollEnabled = false
  }

  public required init(component: Component) {
    self.component = component
    super.init()

    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))

    layout.minimumInteritemSpacing = component.meta(GridSpot.Key.minimumInteritemSpacing, Default.Flow.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridSpot.Key.minimumLineSpacing, Default.Flow.minimumLineSpacing)
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
}
