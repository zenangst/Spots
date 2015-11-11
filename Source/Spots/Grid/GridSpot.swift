import UIKit
import GoldenRetriever
import Sugar
import Hex
import Compass

public class GridSpot: NSObject, Spotable {

  public static var cells = [String: UICollectionViewCell.Type]()
  let cellPrefix = "GridSpotCell"
  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  public lazy var flowLayout: UICollectionViewFlowLayout = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsetsZero

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)

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

    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = GridSpot.cells[item.kind] ?? GridSpotCell.self
      collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "\(cellPrefix)\(item.kind.capitalizedString)")

      if let gridCell = componentCellClass.init() as? Itemble {
        self.component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
        self.component.items[index].size.height = gridCell.size.height
      }
    }

    collectionView.backgroundColor = UIColor(hex:
      component.meta.property("background-color") ?? "FFFFFF")
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    flowLayout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    flowLayout.minimumInteritemSpacing = itemSpacing
  }

  public func render() -> UIView {
    collectionView.frame.size.height = flowLayout.collectionViewContentSize().height
    collectionView.frame.size.width = flowLayout.collectionViewContentSize().width

    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }
}

extension GridSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span)
    let item = component.items[indexPath.item]
    return CGSize(width: item.size.width - flowLayout.sectionInset.left, height: item.size.height)
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
    var item = component.items[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("\(cellPrefix)\(item.kind.capitalizedString)", forIndexPath: indexPath)
    cell.optimize()

    if let grid = cell as? Itemble {
      grid.configure(&item)
      component.items[indexPath.item] = item
      collectionView.collectionViewLayout.invalidateLayout()
      sizeDelegate?.sizeDidUpdate()
    }

    return cell
  }
}
