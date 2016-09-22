import Brick
import UIKit
import Sugar

extension ListAdapter {

  public func ui<T>(atIndex index: Int) -> T? {
    return spot.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? T
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let count = spot.component.items.count
    spot.component.items.append(item)

    dispatch { [weak self] in
      self?.spot.tableView.insert([count], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }

    spot.configureItem(count)
  }

  /**
   - Parameter item: A collection of view models that you want to insert
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.appendContentsOf(items)

    items.enumerate().forEach {
      indexes.append(count + $0.index)
      spot.configureItem(count + $0.index)
    }

    dispatch { [weak self] in
      self?.spot.tableView.insert(indexes, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot.component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      self?.spot.tableView.insert([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    dispatch { [weak self, spot = spot] in
      items.enumerate().forEach {
        let index = items.count - 1 - $0.index
        indexes.append(index)
        spot.configureItem(index)
      }

      self?.spot.tableView.insert(indexes, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    spot.component.items.removeAtIndex(index)

    dispatch { [weak self] in
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: A collection of view models that you want to delete
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      spot.component.items.append(item)
    }

    dispatch { [weak self] in
      self?.spot.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      self?.spot.component.items.removeAtIndex(index)
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      indexes.forEach { self?.spot.component.items.removeAtIndex($0) }
      self?.spot.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been updated
   */
  public func update(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let oldItem = spot.item(index) else { completion?(); return }

    spot.items[index] = item
    spot.configureItem(index)

    let newItem = spot.items[index]
    let indexPath = NSIndexPath(forRow: index, inSection: 0)

    if let composite = spot.tableView.cellForRowAtIndexPath(indexPath) as? SpotComposable,
      spots = spot.spotsCompositeDelegate?.resolve(spotIndex: spot.index, itemIndex: indexPath.item) {
      spot.tableView.beginUpdates()
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
      spot.tableView.endUpdates()
      spot.updateHeight() {
        completion?()
      }
      return
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.tableView.cellForRowAtIndexPath(indexPath) as? SpotConfigurable where animation != .None {
        spot.tableView.beginUpdates()
        cell.configure(&spot.items[index])
        spot.tableView.endUpdates()
      } else {
        spot.tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
      }

      spot.prepareItems()
      spot.updateHeight() { completion?() }
    } else if let cell = spot.tableView.cellForRowAtIndexPath(indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animated: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    spot.refreshIndexes()

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(index)
      }
    } else {
      for (index, _) in spot.component.items.enumerate() {
        spot.configureItem(index)
      }
    }

    if let indexes = indexes {
      spot.tableView.reload(indexes, animation: animation.tableViewAnimation)
    } else {
      animation != .None
        ? spot.tableView.reloadSection(0, animation: animation.tableViewAnimation)
        : spot.tableView.reloadData()
    }

    UIView.setAnimationsEnabled(true)
    spot.updateHeight()
    completion?()
  }

  /**
   Process updates and determine if the updates are done

   - parameter updates:    A collection of updates
   - parameter completion: A completion closure that is run when the updates are finished
   */
  public func process(updates: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion) {
    guard !updates.isEmpty else { completion?(); return }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.spot.item(index) else { completion?(); continue }
      self.update(item, index: index, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /**
   Reload spot with ViewModelChanges

   - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children
   - parameter updateDataSource: A closure to update your data source
   - parameter completion:       A completion closure that runs when your updates are done
   */
  public func reloadIfNeeded(changes: ViewModelChanges, withAnimation animation: SpotsAnimation = .Automatic, updateDataSource: () -> Void, completion: Completion) {
    spot.tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), withAnimation: animation.tableViewAnimation, updateDataSource: updateDataSource) {
      if changes.updates.isEmpty {
        self.process(changes.updatedChildren, withAnimation: animation, completion: completion)
      } else {
        self.process(changes.updates) {
          self.process(changes.updatedChildren, withAnimation: animation, completion: completion)
        }
      }
    }
  }
}
