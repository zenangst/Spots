import UIKit
import GoldenRetriever
import Sugar

class GridSpot: NSObject, Spotable {

  static var cells = [String: UICollectionViewCell.Type]()

  var component: Component
  weak var sizeDelegate: SpotSizeDelegate?

  lazy var flowLayout: UICollectionViewFlowLayout = {
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.itemSize = CGSize(width: floor(size), height: 88)

    return layout
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.delegate = self

    return collectionView
    }()

  required init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      let componentCellClass = GridSpot.cells[item.type] ?? GridSpotCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "GridSpotCell\(item.type.capitalizedString)")
    }
  }

  func render() -> UIView {
    collectionView.frame.size.height = flowLayout.collectionViewContentSize().height
    return collectionView
  }

  func layout(size: CGSize) {
    collectionView.frame.size.width = size.width
    collectionView.collectionViewLayout.invalidateLayout()
  }
}

extension GridSpot: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath)

    var height: CGFloat = 88
    if let grid = cell as? Gridable {
      height = grid.size.height
    }

    let newSize = collectionView.frame.width / CGFloat(self.component.span) - 2

    return CGSize(width: floor(newSize), height: height)
  }
}

extension GridSpot: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = component.items[indexPath.item]

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GridSpotCell\(item.type.capitalizedString)", forIndexPath: indexPath)

    if let grid = cell as? Gridable {
      grid.configure(item)
    }

    return cell
  }
}
