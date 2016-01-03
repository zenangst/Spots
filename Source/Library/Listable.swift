import UIKit
import Sugar

public protocol Listable: Spotable {
  var tableView: UITableView { get }

  func append(item: ListItem, completion: (() -> Void)?)
  func append(items: [ListItem], completion: (() -> Void)?)
  func prepend(items: [ListItem], completion: (() -> Void)?)
  func delete(item: ListItem, completion: (() -> Void)?)
  func delete(items: [ListItem], completion: (() -> Void)?)
}

public extension Spotable where Self : Listable {

  public func prepare() {
    prepareSpot(self)
  }

  private func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "list" }

    for (reuseIdentifier, classType) in T.cells {
      tableView.registerClass(classType, forCellReuseIdentifier: reuseIdentifier)
    }

    if !T.cells.keys.contains(component.kind) {
      tableView.registerClass(T.defaultCell, forCellReuseIdentifier: component.kind)
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

  public func append(item: ListItem, completion: (() -> Void)? = nil) {
    component.items.append(item)

    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func append(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      component.items.append(item)
      indexPaths.append(NSIndexPath(forRow: count + index, inSection: 0))
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.tableView.beginUpdates()
        weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        weakSelf.tableView.endUpdates()
      } else {
        weakSelf.tableView.reloadData()
      }

      completion?()
    }
  }

  public func prepend(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()

    for (index, item) in items.enumerate() {
      indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
      component.items.insert(item, atIndex: index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func delete(item: ListItem, completion: (() -> Void)? = nil) {
    guard let index = component.items.indexOf({ $0 == item})
      else { completion?(); return }

    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))
    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func delete(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(NSIndexPath(forRow: count + index, inSection: 0))
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func update(item: ListItem, index: Int, completion: (() -> Void)? = nil) {
    items[index] = item

    let cellClass = self.dynamicType.cells[item.kind] ?? self.dynamicType.defaultCell
    let reuseIdentifier = !component.items[index].kind.isEmpty
      ? component.items[index].kind
      : component.kind

    tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
    if let cell = cellClass.init() as? Itemble {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    tableView.endUpdates()

    completion?()
  }

  public func reload(indexes: [Int] = [], completion: (() -> Void)? = nil) {
    let items = component.items

    for (index, item) in items.enumerate() {
      let cellClass = self.dynamicType.cells[item.kind] ?? self.dynamicType.defaultCell
      let reuseIdentifier = !component.items[index].kind.isEmpty
        ? component.items[index].kind
        : component.kind

      tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
      if let cell = cellClass.init() as? Itemble {
        component.items[index].index = index
        cell.configure(&component.items[index])
      }
    }

    tableView.beginUpdates()
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    tableView.endUpdates()
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
}
