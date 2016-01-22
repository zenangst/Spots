import UIKit
import Sugar

public protocol Listable: Spotable {
  var tableView: UITableView { get }
}

public extension Spotable where Self : Listable {

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
    for (index, item) in component.items.enumerate() {
      prepareItem(item, index: index, spot: self, cached: &cached)
    }
    cached = nil
  }

  func prepareItem<T: Spotable>(item: ListItem, index: Int, spot: T, inout cached: UIView?) {
    let reuseIdentifer = item.kind.isEmpty ? component.kind : item.kind
    let componentClass = T.views[reuseIdentifer] ?? T.defaultView

    component.items[index].index = index

    if cached?.isKindOfClass(componentClass) == false { cached = nil }
    if cached == nil { cached = componentClass.init() }

    (cached as? Itemble)?.configure(&component.items[index])
  }

  public func append(item: ListItem, completion: (() -> Void)? = nil) {
    let count = component.items.count
    component.items.append(item)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.insert([count], animation: .Top)
      completion?()
    }
    var cached: UIView?
    prepareItem(item, index: count, spot: self, cached: &cached)
    cached = nil
  }

  public func append(items: [ListItem], completion: (() -> Void)? = nil) {
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
      guard let weakSelf = self else { return }
      weakSelf.tableView.insert(indexes, animation: .Bottom)
      completion?()
    }
  }

  public func insert(item: ListItem, index: Int, completion: (() -> Void)? = nil) {
    component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.tableView.insert([index], animation: .Top)
      completion?()
    }
  }

  public func prepend(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexes = [Int]()

    component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.tableView.insert(indexes, animation: .Top)
      completion?()
    }
  }

  public func delete(item: ListItem, completion: (() -> Void)? = nil) {
    guard let index = component.items.indexOf({ $0 == item})
      else { completion?(); return }

    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.tableView.delete([index])
      completion?()
    }
  }

  public func delete(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.tableView.delete(indexPaths)
      completion?()
    }
  }

  func delete(index: Int, completion: (() -> Void)? = nil) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.component.items.removeAtIndex(index)
      weakSelf.tableView.delete([index])
      completion?()
    }
  }

  func delete(indexes: [Int], completion: (() -> Void)? = nil) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      indexes.forEach { weakSelf.component.items.removeAtIndex($0) }
      weakSelf.tableView.delete(indexes, section: 0, animation: .Automatic)
      completion?()
    }
  }

  public func update(item: ListItem, index: Int, completion: (() -> Void)? = nil) {
    items[index] = item

    let cellClass = self.dynamicType.views[item.kind] ?? self.dynamicType.defaultView
    let reuseIdentifier = !component.items[index].kind.isEmpty
      ? component.items[index].kind
      : component.kind

    tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
    if let cell = cellClass.init() as? Itemble {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    tableView.reload([index], section: 0, animation: .None)
    completion?()
  }

  public func reload(indexes: [Int] = [], completion: (() -> Void)? = nil) {
    let items = component.items

    for (index, item) in items.enumerate() {
      let cellClass = self.dynamicType.views[item.kind] ?? self.dynamicType.defaultView
      let reuseIdentifier = !component.items[index].kind.isEmpty
        ? component.items[index].kind
        : component.kind

      tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
      if let cell = cellClass.init() as? Itemble {
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
    tableView.frame.size.width = size.width
    tableView.layoutIfNeeded()
  }

  public func scrollTo(@noescape includeElement: (ListItem) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    let height = component.items[0...item.index].reduce(0, combine: { $0 + $1.size.height })

    return height
  }
}
