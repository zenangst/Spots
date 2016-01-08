import Cocoa
import Sugar

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

  public func prepare() {
    prepareSpot(self)
  }

  public func append(item: ListItem, completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      component.items.append(item)
      indexes.append(count + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  public func append(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      component.items.append(item)
      indexes.append(count + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  public func insert(item: ListItem, index: Int, completion: (() -> Void)? = nil) {
    component.items.insert(item, atIndex: index)
    var indexes = [Int]()
    let count = component.items.count

    indexes.append(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  public func prepend(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexes.append(items.count - index)
      component.items.insert(item, atIndex: 0)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  public func delete(item: ListItem, completion: (() -> Void)? = nil) {
    guard let index = component.items.indexOf({ $0 == item})
      else { completion?(); return }

    var indexes = [Int]()
    indexes.append(component.items.count)
    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  public func delete(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexes.append(count + index)
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  func delete(index: Int, completion: (() -> Void)?) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete([index], completion: completion)
    }
  }

  func delete(indexes: [Int], completion: (() -> Void)?) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  public func update(item: ListItem, index: Int, completion: (() -> Void)? = nil) {
    items[index] = item

    let cellClass = self.dynamicType.cells[item.kind] ?? self.dynamicType.defaultCell
    let reuseIdentifier = !component.items[index].kind.isEmpty
      ? component.items[index].kind
      : component.kind

    collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    if let cell = cellClass.init() as? Itemble {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.reload([index])
    }
  }

  private func prepareSpot<T: Spotable>(spot: T) {
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
        component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
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
    collectionView.layoutIfNeeded()
    completion?()
  }

  public func render() -> UIScrollView {
    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
    guard let componentSize = component.size else { return }
    collectionView.frame.size.height = componentSize.height
  }
}
