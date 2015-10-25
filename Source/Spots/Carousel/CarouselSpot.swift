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
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .Horizontal

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()

    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = GridSpot.cells[item.kind] ?? CarouselSpotCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "CarouselCell\(item.kind.capitalizedString)")

      if let gridCell = componentCellClass.init() as? Itemble {
        self.component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
        self.component.items[index].size.height = gridCell.size.height
      }
    }
  }

  public func render() -> UIView {
    if let first = component.items.first {
      collectionView.frame.size.height = first.size.height
    }

    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }
}

extension CarouselSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = collectionView.frame.width
    let item = component.items[indexPath.item]
    return CGSize(width: item.size.width, height: item.size.height)
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
      sizeDelegate?.sizeDidUpdate()
    }

    return cell
  }
}
