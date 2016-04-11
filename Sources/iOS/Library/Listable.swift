import UIKit
import Sugar
import Brick

public protocol Listable: Spotable {
  var tableView: UITableView { get }
}

public extension Spotable where Self : Listable {

  typealias Completion = (() -> Void)?

  public func prepare() {
    prepareSpot(self)
  }

  private func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "list" }

    for (reuseIdentifier, classType) in T.views {
      tableView.registerClass(classType, forCellReuseIdentifier: reuseIdentifier)
    }

    if !T.views.keys.contains(component.kind) {
      tableView.registerClass(T.defaultView, forCellReuseIdentifier: component.kind)
    }

    var cached: UIView?
    defer { cached = nil }

    for (index, item) in component.items.enumerate() {
      prepareItem(item, index: index, spot: self, cached: &cached)
    }
  }

  public func append(item: ViewModel, completion: Completion = nil) {
    let count = component.items.count
    component.items.append(item)

    dispatch { [weak self] in
      self?.tableView.insert([count], animation: .None)
      completion?()
    }
    var cached: UIView?
    defer { cached = nil }

    prepareItem(item, index: count, spot: self, cached: &cached)
  }

  public func append(items: [ViewModel], completion: (() -> Void)? = nil) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.appendContentsOf(items)

    var cached: UIView?
    items.enumerate().forEach {
      indexes.append(count + $0.index)
      prepareItem($0.element, index: count + $0.index, spot: self, cached: &cached)
    }
    cached = nil

    dispatch { [weak self] in
      self?.tableView.insert(indexes, animation: .None)
      completion?()
    }
  }

  public func insert(item: ViewModel, index: Int = 0, completion: Completion = nil) {
    component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      self?.tableView.insert([index], animation: .None)
      completion?()
    }
  }

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

  public func delete(item: ViewModel, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item})
      else { completion?(); return }

    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      self?.tableView.delete([index])
      completion?()
    }
  }

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

  func delete(index: Int, completion: Completion = nil) {
    dispatch { [weak self] in
      self?.component.items.removeAtIndex(index)
      self?.tableView.delete([index])
      completion?()
    }
  }

  func delete(indexes: [Int], completion: Completion = nil) {
    dispatch { [weak self] in
      indexes.forEach { self?.component.items.removeAtIndex($0) }
      self?.tableView.delete(indexes, section: 0, animation: .Automatic)
      completion?()
    }
  }

  public func update(item: ViewModel, index: Int = 0, completion: Completion = nil) {
    items[index] = item

    let cellClass = self.dynamicType.views[item.kind] ?? self.dynamicType.defaultView
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

  public func reload(indexes: [Int]? = nil, completion: Completion = nil) {
    for (index, item) in component.items.enumerate() {
      let cellClass = self.dynamicType.views[item.kind] ?? self.dynamicType.defaultView
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

  public func render() -> UIScrollView {
    return tableView
  }

  public func layout(size: CGSize) {
    tableView.width = size.width
    tableView.layoutIfNeeded()
  }

  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, combine: { $0 + $1.size.height })
  }
}
