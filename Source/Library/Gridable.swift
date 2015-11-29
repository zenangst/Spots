import UIKit

public protocol Gridable: Spotable {
  var layout: UICollectionViewFlowLayout { get }
  var collectionView: UICollectionView { get }
}

public extension Spotable where Self : Gridable {

  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  public func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "grid" }

    for (reuseIdentifier, classType) in T.cells {
      collectionView.registerClass(classType, forCellWithReuseIdentifier: reuseIdentifier)
    }

    if !T.cells.keys.contains(component.kind) {
      collectionView.registerClass(T.defaultCell, forCellWithReuseIdentifier: component.kind)
    }

    for (index, item) in component.items.enumerate() {
      let reuseIdentifer = item.kind.isEmpty ? component.kind : item.kind
      let componentCellClass = T.cells[reuseIdentifer] ?? T.defaultCell

      component.items[index].index = index

      if let cell = componentCellClass.init() as? Itemble {
        cell.configure(&component.items[index])
      }
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
