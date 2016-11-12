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
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }

      let count = weakSelf.component.items.count
      weakSelf.component.items.append(item)

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.tableView.insert([count], animation: animation.tableViewAnimation)
        weakSelf.updateHeight() {
          completion()
        }
      }

      weakSelf.configureItem(at: count)
    }

    operationQueue.addOperation(operation)
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }

      var indexes = [Int]()
      let count = weakSelf.component.items.count

      weakSelf.component.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(count + $0.offset)
        weakSelf.configureItem(at: count + $0.offset)
      }

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.tableView.insert(indexes, animation: animation.tableViewAnimation)
        weakSelf.updateHeight() {
          completion()
        }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func insert(_ item: Item, index: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      weakSelf.component.items.insert(item, at: index)

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.tableView.insert([index], animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func prepend(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      var indexes = [Int]()

      weakSelf.component.items.insert(contentsOf: items, at: 0)

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        items.enumerated().forEach {
          let index = items.count - 1 - $0.offset
          indexes.append(index)
          weakSelf.configureItem(at: index)
        }

        weakSelf.tableView.insert(indexes, animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self,
        let index = weakSelf.component.items.index(where: { $0 == item }) else {
          completion()
          return
      }

      weakSelf.component.items.remove(at: index)

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.tableView.delete([index], animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      var indexPaths = [Int]()
      let count = weakSelf.component.items.count

      for (index, item) in items.enumerated() {
        indexPaths.append(count + index)
        weakSelf.component.items.append(item)
      }

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    let operation = SpotOperation(completion) { completion in
      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }
        weakSelf.component.items.remove(at: index)
        weakSelf.tableView.delete([index], animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    let operation = SpotOperation(completion) { completion in
      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion(); return }

        indexes.forEach {
          weakSelf.component.items.remove(at: $0)
        }

        weakSelf.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
        weakSelf.sanitize { completion() }
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func update(_ item: Item, index: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self,
        let oldItem = weakSelf.item(at: index) else {
          completion()
          return
      }

      weakSelf.items[index] = item
      weakSelf.configureItem(at: index)

      let newItem = weakSelf.items[index]
      let indexPath = IndexPath(row: index, section: 0)

      if let composite = weakSelf.tableView.cellForRow(at: indexPath) as? Composable,
        let spots = weakSelf.spotsCompositeDelegate?.resolve(index, itemIndex: (indexPath as NSIndexPath).item) {
        weakSelf.tableView.beginUpdates()
        composite.configure(&weakSelf.component.items[indexPath.item], spots: spots)
        weakSelf.tableView.endUpdates()
        weakSelf.updateHeight() {
          completion()
        }
        return
      }

      if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
        if let cell = weakSelf.tableView.cellForRow(at: indexPath) as? SpotConfigurable, animation != .none {
          weakSelf.tableView.beginUpdates()
          cell.configure(&weakSelf.items[index])
          weakSelf.tableView.endUpdates()
        } else {
          weakSelf.tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
        }
        weakSelf.updateHeight() { completion() }
        return
      } else if let cell = weakSelf.tableView.cellForRow(at: indexPath) as? SpotConfigurable {
        cell.configure(&weakSelf.items[index])
        weakSelf.updateHeight() { completion() }
      } else {
        completion()
      }
    }
    operationQueue.addOperation(operation)
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter animation:  A Animation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  public func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      weakSelf.refreshIndexes()

      if let indexes = indexes {
        indexes.forEach { index  in
          weakSelf.configureItem(at: index)
        }
      } else {
        for (index, _) in weakSelf.component.items.enumerated() {
          weakSelf.configureItem(at: index)
        }
      }

      if let indexes = indexes {
        weakSelf.tableView.reload(indexes, animation: animation.tableViewAnimation)
      } else {
        animation != .none
          ? weakSelf.tableView.reloadSection(0, animation: animation.tableViewAnimation)
          : weakSelf.tableView.reloadData()
      }

      weakSelf.updateHeight() {
        completion()
      }
    }
    operationQueue.addOperation(operation)
  }
}
