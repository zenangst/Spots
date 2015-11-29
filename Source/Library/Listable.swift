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

  public func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "list" }

    if !component.items.isEmpty {
      for (index, item) in component.items.enumerate() {
        let reuseIdentifer = item.kind.isEmpty ? component.kind : item.kind
        let componentCellClass = T.cells[reuseIdentifer] ?? T.defaultCell

        component.items[index].index = index

        if cellIsCached(component.items[index].kind) {
          cachedCells[reuseIdentifer]!.configure(&component.items[index])
        } else {
          tableView.registerClass(componentCellClass, forCellReuseIdentifier: reuseIdentifer)
          if let cell = componentCellClass.init() as? Itemble {
            cell.configure(&component.items[index])
            cachedCells[reuseIdentifer] = cell
          }
        }
      }
    } else {
      let componentCellClass = T.cells[component.kind] ?? T.defaultCell
      tableView.registerClass(componentCellClass, forCellReuseIdentifier: component.kind)
    }
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

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

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
    completion?()
  }

  public func render() -> UIView {
    return tableView
  }

  public func layout(size: CGSize) {
    tableView.frame.size.width = size.width
    tableView.layoutIfNeeded()
  }
}
