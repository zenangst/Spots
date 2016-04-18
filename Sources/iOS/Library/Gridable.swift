import UIKit
import Sugar
import Brick

public protocol Gridable: Spotable {
  var layout: UICollectionViewFlowLayout { get }
  var collectionView: UICollectionView { get }

  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize
}

public extension Spotable where Self : Gridable {

  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      collectionView.registerClass(classType, forCellWithReuseIdentifier: withIdentifier)
    }

    var cached: UIView?
    for (index, item) in component.items.enumerate() {
      cachedViewFor(item, cache: &cached)

      if component.span > 0 {
        component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
      }
      (cached as? SpotConfigurable)?.configure(&component.items[index])
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter completion: (() -> Void)?
   */
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

  /**
   - Parameter item: A collection of view models that you want to insert
   - Parameter completion: (() -> Void)?
   */
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

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter completion: (() -> Void)?
   */
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

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter completion: A completion closure that is executed in the main queue
   */
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

  /**
   - Parameter item: The view model that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue
   */
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

  /**
   - Parameter item: A collection of view models that you want to delete
   - Parameter completion: A completion closure that is executed in the main queue
   */
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

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, completion: (() -> Void)?) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete([index], completion: completion)
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(indexes: [Int], completion: (() -> Void)?) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func update(item: ViewModel, index: Int, completion: (() -> Void)? = nil) {
    items[index] = item

    let cellClass = self.dynamicType.views.storage[item.kind] ?? self.dynamicType.defaultView
    let reuseIdentifier = component.items[index].kind.isPresent
      ? component.items[index].kind
      : component.kind

    collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    if let cell = cellClass.init() as? SpotConfigurable {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.reload([index], completion: completion)
    }
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, completion: (() -> Void)?) {
    let items = component.items
    for (index, item) in items.enumerate() {
      let cellClass = self.dynamicType.views.storage[item.kind] ?? self.dynamicType.defaultView
      if let cell = cellClass.init() as? SpotConfigurable {
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

  /**
   - Returns: UIScrollView: Returns a UICollectionView as a UIScrollView
   */
  public func render() -> UIScrollView {
    return collectionView
  }

  /**
   - Parameter size: A CGSize to set the size of the collection view
   */
  public func setup(size: CGSize) {
    collectionView.frame.size = size
    GridSpot.configure?(view: collectionView)
  }

  /**
   - Parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.width = size.width
    guard let componentSize = component.size else { return }
    collectionView.height = componentSize.height
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      component.items[indexPath.item].size.width = collectionView.width / CGFloat(component.span) - layout.minimumInteritemSpacing
    }

    return CGSize(
      width: ceil(item(indexPath).size.width - layout.sectionInset.left - layout.sectionInset.right),
      height: ceil(item(indexPath).size.height))
  }
}
