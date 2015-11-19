import UIKit
import Sugar

public protocol Listable: Spotable {
  var tableView: UITableView { get }
}

public extension Spotable where Self : Listable {

  public func prepareSpot<T: Spotable>(spot: T) {
    for (index, item) in component.items.enumerate() {
      sanitizeItems()

      let componentCellClass = T.cells[item.kind] ?? T.defaultCell

      if cellIsCached(component.items[index].kind) {
        cachedCells[item.kind]!.configure(&self.component.items[index])
      } else {
        tableView.registerClass(componentCellClass, forCellReuseIdentifier: self.component.items[index].kind)
        if let cell = componentCellClass.init() as? Itemble {
          cell.configure(&self.component.items[index])
          cachedCells[item.kind] = cell
        }
      }
    }
  }
  
  private func cache<T: Spotable>(spot: T, identifier: String) -> Bool {
    if !cellIsCached(identifier) {
      let componentCellClass = T.cells[identifier] ?? T.defaultCell
      tableView.registerClass(componentCellClass, forCellReuseIdentifier: component.items[index].kind)
      
      if let feedCell = componentCellClass.init() as? Itemble {
        cachedCells[identifier] = feedCell
      }
      return false
    } else {
      return true
    }
  }

  public func append(item: ListItem, completion: (() -> Void)? = nil) {
    cache(self, identifier: item.kind)

    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))
    component.items.append(item)

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
      cache(self, identifier: item.kind)
      indexPaths.append(NSIndexPath(forRow: count + index, inSection: 0))
      component.items.append(item)
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
    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))
    component.items.append(item)

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
      let componentCellClass = ListSpot.cells[item.kind] ?? ListSpot.defaultCell
      tableView.registerClass(componentCellClass,
        forCellReuseIdentifier: component.items[index].kind)
      if let listCell = componentCellClass.init() as? Itemble {
        component.items[index].index = index
        listCell.configure(&component.items[index])
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
