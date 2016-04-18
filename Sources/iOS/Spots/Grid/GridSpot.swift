import UIKit
import Sugar

public class GridSpot: NSObject, Gridable {

  public static var views = ViewRegistry()
  public static var defaultView: UIView.Type = GridSpotCell.self
  public static var defaultKind = "grid"
  public static var configure: ((view: UICollectionView) -> Void)?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var index = 0
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsDelegate: SpotsDelegate?

  public lazy var adapter: CollectionAdapter = CollectionAdapter(spot: self)
  public lazy var layout = UICollectionViewFlowLayout()

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout).then {
    $0.backgroundColor = UIColor.whiteColor()
    $0.dataSource = self.adapter
    $0.delegate = self.adapter
    $0.scrollEnabled = false
  }

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind))
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }
}
