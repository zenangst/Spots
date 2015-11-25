import UIKit

public protocol Gridable: Spotable {
  var collectionView: UICollectionView { get }
}

public extension Spotable where Self : Gridable {

  public func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "grid" }

    if !component.items.isEmpty {
      for (index, item) in component.items.enumerate() {
        component.index = index
        let cellClass = T.cells[item.kind] ?? T.defaultCell
        collectionView.registerClass(cellClass,
          forCellWithReuseIdentifier: component.items[index].kind)

        if let cell = cellClass.init() as? Itemble {
          component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
          component.items[index].size.height = cell.size.height
        }
      }
    } else {
      let cellClass = T.cells[component.kind] ?? T.defaultCell
      collectionView.registerClass(cellClass,
        forCellWithReuseIdentifier: component.kind)
    }
  }

  public func reload(indexes: [Int] = [], completion: (() -> Void)?) {
    let items = component.items
    for (index, item) in items.enumerate() {
      let cellClass = self.dynamicType.cells[item.kind] ?? self.dynamicType.defaultCell
      if let cell = cellClass.init() as? Itemble {
        component.items[index].index = index
        cell.configure(&component.items[index])
      }
    }

    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.reloadData()
    setup(collectionView.bounds.size)
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
