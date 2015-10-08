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
    for item in component.items {
      let componentCellClass = GridSpot.cells[item.kind] ?? GridSpotCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "\(cellPrefix)\(item.kind.capitalizedString)")
    }
  }

  public func render() -> UIView {
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
    let height: CGFloat = 88
    let newSize = collectionView.frame.width / CGFloat(self.component.span)

    return CGSize(width: floor(newSize), height: height)
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
