import UIKit

public protocol Gridable: Spotable {
  var collectionView: UICollectionView { get }
}

public extension Spotable where Self : Gridable {

  public func prepareSpot<T: Spotable>(spot: T) {
    for (index, item) in component.items.enumerate() {
      sanitizeItems()
      self.component.index = index
      let componentCellClass = T.cells[item.kind] ?? T.defaultCell
      collectionView.registerClass(componentCellClass,
        forCellWithReuseIdentifier: component.items[index].kind)

      if let cell = componentCellClass.init() as? Itemble {
        self.component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
        self.component.items[index].size.height = cell.size.height
      }
    }
  }

  public func reload(indexes: [Int] = [], completion: (() -> Void)?) {
    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = self.dynamicType.cells[item.kind] ?? self.dynamicType.defaultCell
      if let listCell = componentCellClass.init() as? Itemble {
        component.items[index].index = index
        listCell.configure(&component.items[index])
      }
    }

    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.reloadData()
    setup()
    completion?()
  }

  public func render() -> UIView {
    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }
}
