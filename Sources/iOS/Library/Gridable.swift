import UIKit
import Sugar
import Brick

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

  public func append(item: ViewModel, completion: (() -> Void)? = nil) {
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

  public func append(items: [ViewModel], completion: (() -> Void)? = nil) {
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

  public func insert(item: ViewModel, index: Int, completion: (() -> Void)? = nil) {
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

  public func prepend(items: [ViewModel], completion: (() -> Void)? = nil) {
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

  public func delete(item: ViewModel, completion: (() -> Void)? = nil) {
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

  public func delete(items: [ViewModel], completion: (() -> Void)? = nil) {
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

  public func update(item: ViewModel, index: Int, completion: (() -> Void)? = nil) {
    items[index] = item

    let info = reusableInfo(item)

    collectionView.registerClass(info.itemClass, forCellWithReuseIdentifier: info.identifier)

    if let cell = info.itemClass.init() as? SpotConfigurable {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.reload([index], completion: completion)
    }
  }

  public func reload(indexes: [Int]? = nil, completion: (() -> Void)?) {
    let items = component.items
    for (index, item) in items.enumerate() {
      let info = reusableInfo(item)

      if let cell = info.itemClass.init() as? SpotConfigurable {
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

  public func setup(size: CGSize) {
    collectionView.frame.size = size
    GridSpot.configure?(view: collectionView)
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.width = size.width
    guard let componentSize = component.size else { return }
    collectionView.height = componentSize.height
  }
}
