import UIKit
import Brick

// MARK: - Extensions for Spotable objects that also confirm to Listable
public extension Listable {

  /// Return table view as a scroll view
  ///
  /// - returns: UIScrollView: Returns a UITableView as a UIScrollView
  ///
  public func render() -> UIScrollView {
    return tableView
  }

  /// Layout using size
  /// - parameter size: A CGSize to set the width of the table view
  ///
  public func layout(_ size: CGSize) {
    tableView.frame.size.width = size.width
    guard let componentSize = component.size else { return }
    tableView.frame.size.height = componentSize.height
  }

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  public func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, { $0 + $1.size.height })
  }
}

extension Listable {

  /// Find a generic UI component at index
  ///
  /// - parameter index: The index of the UI that you are looking for
  ///
  /// - returns: An optional generic type, this type will inherit from UITableViewcell
  public func ui<T>(at index: Int) -> T? {
    return tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? T
  }

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ item: Item, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let count = component.items.count
    component.items.append(item)

    Dispatch.mainQueue { [weak self] in
      self?.tableView.insert([count], animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }

    configureItem(at: count)
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.append(contentsOf: items)

    items.enumerated().forEach {
      indexes.append(count + $0.offset)
      configureItem(at: count + $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      self?.tableView.insert(indexes, animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func insert(_ item: Item, index: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      self?.tableView.insert([index], animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func prepend(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    var indexes = [Int]()

    component.items.insert(contentsOf: items, at: 0)

    Dispatch.mainQueue { [weak self] in
      items.enumerated().forEach {
        let index = items.count - 1 - $0.offset
        indexes.append(index)
        self?.configureItem(at: index)
      }

      self?.tableView.insert(indexes, animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let index = component.items.index(where: { $0 == item })
      else { completion?(); return }

    component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      self?.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerated() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    Dispatch.mainQueue { [weak self] in
      self?.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      self?.component.items.remove(at: index)
      self?.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.component.items.remove(at: $0) }
      self?.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
      self?.updateHeight() {
        completion?()
      }
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func update(_ item: Item, index: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = self.item(at: index) else { completion?(); return }

    items[index] = item
    configureItem(at: index)

    let newItem = items[index]
    let indexPath = IndexPath(row: index, section: 0)

    if let composite = tableView.cellForRow(at: indexPath) as? Composable,
      let spots = spotsCompositeDelegate?.resolve(index, itemIndex: (indexPath as NSIndexPath).item) {
      tableView.beginUpdates()
      composite.configure(&component.items[indexPath.item], spots: spots)
      tableView.endUpdates()
      updateHeight() {
        completion?()
      }
      return
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = tableView.cellForRow(at: indexPath) as? SpotConfigurable, animation != .none {
        tableView.beginUpdates()
        cell.configure(&items[index])
        tableView.endUpdates()
      } else {
        tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
      }
      updateHeight() { completion?() }
      return
    } else if let cell = tableView.cellForRow(at: indexPath) as? SpotConfigurable {
      cell.configure(&items[index])
    }
    completion?()
  }

  /**
   Process updates and determine if the updates are done

   - parameter updates:    A collection of updates
   - parameter animation:  A Animation that is used when performing the mutation
   - parameter completion: A completion closure that is run when the updates are finished
   */
  public func process(_ updates: [Int], withAnimation animation: Animation = .automatic, completion: Completion) {
    guard !updates.isEmpty else { completion?(); return }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.item(at: index) else { completion?(); continue }
      self.update(item, index: index, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), withAnimation: animation.tableViewAnimation, updateDataSource: updateDataSource) {
      if changes.updates.isEmpty {
        self.process(changes.updatedChildren, withAnimation: animation, completion: completion)
      } else {
        self.process(changes.updates) {
          self.process(changes.updatedChildren, withAnimation: animation, completion: completion)
        }
      }
    }
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter animation:  A Animation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  public func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    refreshIndexes()

    if let indexes = indexes {
      indexes.forEach { index  in
        configureItem(at: index)
      }
    } else {
      for (index, _) in component.items.enumerated() {
        configureItem(at: index)
      }
    }

    if let indexes = indexes {
      tableView.reload(indexes, animation: animation.tableViewAnimation)
    } else {
      animation != .none
        ? tableView.reloadSection(0, animation: animation.tableViewAnimation)
        : tableView.reloadData()
    }

    UIView.setAnimationsEnabled(true)
    updateHeight()
    completion?()
  }
}
