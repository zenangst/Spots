import UIKit
import Sugar
import Brick

public protocol Listable: Spotable {
  var tableView: UITableView { get }
}

public extension Spotable where Self : Listable {

  typealias Completion = (() -> Void)?

  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      tableView.registerClass(classType, forCellReuseIdentifier: withIdentifier)
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter completion: (() -> Void)?
   */
  public func append(item: ViewModel, completion: Completion = nil) {
    let count = component.items.count
    component.items.append(item)

    dispatch { [weak self] in
      self?.tableView.insert([count], animation: .None)
      completion?()
    }
    var cached: UIView?
    prepareItem(item, index: count, cached: &cached)
  }

  /**
   - Parameter item: A collection of view models that you want to insert
   - Parameter completion: (() -> Void)?
   */
  public func append(items: [ViewModel], completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.appendContentsOf(items)

    var cached: UIView?
    items.enumerate().forEach {
      indexes.append(count + $0.index)
      prepareItem($0.element, index: count + $0.index, cached: &cached)
    }

    dispatch { [weak self] in
      self?.tableView.insert(indexes, animation: .None)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter completion: (() -> Void)?
   */
  public func insert(item: ViewModel, index: Int = 0, completion: Completion = nil) {
    component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      self?.tableView.insert([index], animation: .None)
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], completion: Completion = nil) {
    var indexes = [Int]()

    component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    dispatch { [weak self] in
      self?.tableView.insert(indexes, animation: .None)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item})
      else { completion?(); return }

    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      self?.tableView.delete([index])
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view models that you want to delete
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    dispatch { [weak self] in
      self?.tableView.delete(indexPaths)
      completion?()
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, completion: Completion = nil) {
    dispatch { [weak self] in
      self?.component.items.removeAtIndex(index)
      self?.tableView.delete([index])
      completion?()
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(indexes: [Int], completion: Completion = nil) {
    dispatch { [weak self] in
      indexes.forEach { self?.component.items.removeAtIndex($0) }
      self?.tableView.delete(indexes, section: 0, animation: .Automatic)
      completion?()
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func update(item: ViewModel, index: Int = 0, completion: Completion = nil) {
    items[index] = item

    let cellClass = self.dynamicType.views.storage[item.kind] ?? self.dynamicType.defaultView
    let reuseIdentifier = component.items[index].kind.isPresent
      ? component.items[index].kind
      : component.kind

    tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)

    if let cell = cellClass.init() as? SpotConfigurable {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    tableView.reload([index], section: 0, animation: .None)
    completion?()
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, completion: Completion = nil) {
    refreshIndexes()

    for (index, item) in component.items.enumerate() {
      let cellClass = self.dynamicType.views.storage[item.kind] ?? self.dynamicType.defaultView
      let reuseIdentifier = component.items[index].kind.isPresent
        ? component.items[index].kind
        : component.kind

      tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)

      if let cell = cellClass.init() as? SpotConfigurable {
        component.items[index].index = index
        cell.configure(&component.items[index])
      }
    }

    tableView.reloadSection()
    tableView.setNeedsLayout()
    tableView.layoutIfNeeded()
    completion?()
  }

  /**
   - Returns: UIScrollView: Returns a UITableView as a UIScrollView
   */
  public func render() -> UIScrollView {
    return tableView
  }

  /**
   - Parameter size: A CGSize to set the width of the table view
   */
  public func layout(size: CGSize) {
    tableView.width = size.width
    tableView.layoutIfNeeded()
  }

  /**
   - Parameter includeElement: A filter predicate to find a view model
   - Returns: A calculate CGFloat based on what the includeElement matches
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, combine: { $0 + $1.size.height })
  }
}
