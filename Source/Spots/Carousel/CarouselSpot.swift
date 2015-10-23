import UIKit
import GoldenRetriever
import Sugar

public class CarouselSpot: NSObject, Spotable {

  public static var cells = [String: UICollectionViewCell.Type]()

  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?

  public lazy var flowLayout: UICollectionViewFlowLayout = {
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: floor(size), height: 125)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .Horizontal

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      let componentCellClass = GridSpot.cells[item.kind] ?? CarouselSpotCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "CarouselCell\(item.kind.capitalizedString)")
    }
  }

  public func render() -> UIView {
    collectionView.frame.size.height = flowLayout.itemSize.height

    return collectionView
  }

  public func layout(size: CGSize) {
    let newSize = size.width / CGFloat(self.component.span)
    flowLayout.itemSize = CGSize(width: floor(newSize), height: flowLayout.itemSize.height)
    collectionView.frame.size.width = size.width
  }
}

extension CarouselSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var item = component.items[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CarouselCell\(item.kind.capitalizedString)", forIndexPath: indexPath)

    if let grid = cell as? Itemble {
      grid.configure(&item)
      component.items[indexPath.item] = item
      collectionView.collectionViewLayout.invalidateLayout()
    }

    return cell
  }
}
