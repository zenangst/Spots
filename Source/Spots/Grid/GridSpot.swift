import UIKit
import Hex

public class GridSpot: NSObject, Spotable, Gridable {

  public static var cells = [String: UIView.Type]()
  public static var defaultCell: UIView.Type = GridSpotCell.self
  public static var configure: ((view: UICollectionView) -> Void)?

  public var index = 0
  public var component: Component
  public var cachedCells = [String : Itemble]()

  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  public lazy var layout: UICollectionViewFlowLayout = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsetsZero

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)

    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.scrollEnabled = false

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()

    prepareSpot(self)

    collectionView.backgroundColor = UIColor(hex:
      component.meta.property("background-color") ?? "FFFFFF")
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  public func setup() {
    collectionView.frame.size.height = layout.collectionViewContentSize().height
    collectionView.frame.size.width = layout.collectionViewContentSize().width

    GridSpot.configure?(view: collectionView)
  }
}

extension GridSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span)
    let item = component.items[indexPath.item]
    return CGSize(width: item.size.width - layout.sectionInset.left, height: item.size.height)
  }
}

extension GridSpot: UICollectionViewDelegate {
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let item = component.items[indexPath.item]
    spotDelegate?.spotDidSelectItem(self, item: item)
  }
}

extension GridSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    component.items[indexPath.item].index = indexPath.row
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(component.items[indexPath.item].kind, forIndexPath: indexPath)
    cell.optimize()

    if let grid = cell as? Itemble {
      grid.configure(&component.items[indexPath.item])
      collectionView.collectionViewLayout.invalidateLayout()
      sizeDelegate?.sizeDidUpdate()
    }

    return cell
  }
}
