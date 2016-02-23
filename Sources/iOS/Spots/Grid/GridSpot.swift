import UIKit
import Sugar

public class GridSpot: NSObject, Spotable, Gridable {

  public static var views = [String: UIView.Type]()
  public static var defaultView: UIView.Type = GridSpotCell.self
  public static var configure: ((view: UICollectionView) -> Void)?

  public var cachedViews = [String : ViewConfigurable]()
  public var component: Component
  public var index = 0

  public weak var spotsDelegate: SpotsDelegate?

  public lazy var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.scrollEnabled = false

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(title: String = "", kind: String = "grid") {
    self.init(component: Component(title: title, kind: kind))
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
      component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span) - layout.minimumInteritemSpacing
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

    let reuseIdentifier = !item(indexPath).kind.isEmpty ? item(indexPath).kind : component.kind
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    cell.optimize()

    if let grid = cell as? ViewConfigurable {
      grid.configure(&component.items[indexPath.item])
      collectionView.collectionViewLayout.invalidateLayout()
    }

    return cell
  }
}
