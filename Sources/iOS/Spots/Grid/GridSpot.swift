import UIKit
import Sugar

public class GridSpot: NSObject, Spotable, Gridable {

  public static var views = ViewRegistry()
  public static var defaultView: UIView.Type = GridSpotCell.self
  public static var defaultKind = "grid"
  public static var configure: ((view: UICollectionView) -> Void)?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var index = 0
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsDelegate: SpotsDelegate?

  public lazy var layout = UICollectionViewFlowLayout()

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout).then {
    $0.backgroundColor = UIColor.whiteColor()
    $0.dataSource = self
    $0.delegate = self
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

extension GridSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      component.items[indexPath.item].size.width = collectionView.width / CGFloat(component.span) - layout.minimumInteritemSpacing
    }

    return CGSize(
      width: ceil(item(indexPath).size.width - layout.sectionInset.left - layout.sectionInset.right),
      height: ceil(item(indexPath).size.height))
  }
}

extension GridSpot: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    spotsDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }
}

extension GridSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    component.items[indexPath.item].index = indexPath.row

    let reuseIdentifier = item(indexPath).kind.isPresent ? item(indexPath).kind : component.kind
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath).then { $0.optimize() }

    if let cell = cell as? SpotConfigurable {
      cell.configure(&component.items[indexPath.item])
      if component.items[indexPath.item].size.height == 0.0 {
        component.items[indexPath.item].size = cell.size
      }
      configure?(cell)
    }

    collectionView.collectionViewLayout.invalidateLayout()

    return cell
  }
}
