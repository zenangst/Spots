import UIKit
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

  public static var views = ViewRegistry().then {
    $0.defaultView = GridSpotCell.self
  }

  public static var nibs = NibRegistry()
  public static var defaultView: UIView.Type = GridSpotCell.self
  public static var defaultKind: StringConvertible = "grid"
  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?

  public var cachedViews = [String : SpotConfigurable]()
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
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
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

  // MARK: - Spotable

  public func register() {
    collectionView.registerClass(self.dynamicType.views.defaultView,
                                 forCellWithReuseIdentifier: String(self.dynamicType.views.defaultView))

    self.dynamicType.views.storage.forEach { identifier, type in
      self.collectionView.registerClass(type, forCellWithReuseIdentifier: identifier)
    }
  }

  public func cachedViewFor(item: ViewModel, inout cache: View?) {
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    cache = collectionView.dequeueReusableCellWithReuseIdentifier(item.kind, forIndexPath: indexPath)
  }

  public func dequeueView(identifier: String, indexPath: NSIndexPath) -> View? {
    return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
  }

  public func identifier(index: Int) -> String? {
    guard let kind = item(index)?.kind else { return nil }

    if self.dynamicType.views.storage[kind] != nil {
      return kind
    }

    if self.dynamicType.nibs.storage[kind] != nil {
      return kind
    }

    return nil
  }
}
