import UIKit
import GoldenRetriever
import Sugar

public class GridSpot: NSObject, Spotable {

  public static var cells = [String: UICollectionViewCell.Type]()
  let cellPrefix = "GridSpotCell"
  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?

  public lazy var flowLayout: UICollectionViewFlowLayout = {
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.delegate = self

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()

    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = GridSpot.cells[item.kind] ?? GridSpotCell.self
      collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "\(cellPrefix)\(item.kind.capitalizedString)")

      if let gridItem = componentCellClass.init() as? Gridable {
        self.component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
        self.component.items[index].size.height = gridItem.size.height
      }
    }
  }

  public func render() -> UIView {
    collectionView.frame.size.width = flowLayout.collectionViewContentSize().width
    collectionView.frame.size.height = flowLayout.collectionViewContentSize().height
    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.frame.size.width = size.width
    collectionView.collectionViewLayout.invalidateLayout()
  }
}

extension GridSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span)
    let item = component.items[indexPath.item]
    return CGSize(width: item.size.width, height: item.size.height)
  }
}

extension GridSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = component.items[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("\(cellPrefix)\(item.kind.capitalizedString)", forIndexPath: indexPath)

    if let grid = cell as? Gridable {
      grid.configure(item)
    }

    return cell
  }
}
