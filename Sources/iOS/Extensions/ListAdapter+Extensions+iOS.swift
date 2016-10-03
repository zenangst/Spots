import Brick
import UIKit

extension ListAdapter {

  /**
   Find a generic UI component at index

   - parameter index: The index of the UI that you are looking for

   - returns: An optional generic type, this type will inherit from UITableViewcell
   */
  public func ui<T>(atIndex index: Int) -> T? {
    return spot.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? T
  }

  /**
   - parameter item: The view model that you want to append
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: Completion
   */
  public func append(_ item: Item, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    let count = spot.component.items.count
    spot.component.items.append(item)

    Dispatch.mainQueue { [weak self] in
      self?.spot.tableView.insert([count], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }

    spot.configureItem(count)
  }

  /**
   - parameter items: A collection of view models that you want to insert
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: Completion
   */
  public func append(_ items: [Item], withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.append(contentsOf: items)

    items.enumerated().forEach {
      indexes.append(count + $0.offset)
      spot.configureItem(count + $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      self?.spot.tableView.insert(indexes, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index where the new Item should be inserted
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: Completion
   */
  public func insert(_ item: Item, index: Int = 0, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    spot.component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      self?.spot.tableView.insert([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter items: A collection of view model that you want to prepend
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(_ items: [Item], withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insert(contentsOf: items, at: 0)

    Dispatch.mainQueue { [weak self, spot = spot] in
      items.enumerated().forEach {
        let index = items.count - 1 - $0.offset
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
   - parameter item: The view model that you want to remove
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(_ item: Item, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    guard let index = spot.component.items.index(where: { $0 == item })
      else { completion?(); return }

    spot.component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter items: A collection of view models that you want to delete
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in items.enumerated() {
      indexPaths.append(count + index)
      spot.component.items.append(item)
    }

    Dispatch.mainQueue { [weak self] in
      self?.spot.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(_ index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      self?.spot.component.items.remove(at: index)
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter indexes: An array of indexes that you want to remove
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.spot.component.items.remove(at: $0) }
      self?.spot.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
      self?.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - parameter item: The new update view model that you want to update at an index
   - parameter index: The index of the view model, defaults to 0
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue when the view model has been updated
   */
  public func update(_ item: Item, index: Int = 0, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    guard let oldItem = spot.item(index) else { completion?(); return }

    spot.items[index] = item
    spot.configureItem(index)

    let newItem = spot.items[index]
    let indexPath = IndexPath(row: index, section: 0)

    if let composite = spot.tableView.cellForRow(at: indexPath) as? SpotComposable,
      let spots = spot.spotsCompositeDelegate?.resolve(spotIndex: spot.index, itemIndex: (indexPath as NSIndexPath).item) {
      spot.tableView.beginUpdates()
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
      spot.tableView.endUpdates()
      spot.updateHeight() {
        completion?()
      }
      return
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.tableView.cellForRow(at: indexPath) as? SpotConfigurable, animation != .none {
        spot.tableView.beginUpdates()
        cell.configure(&spot.items[index])
        spot.tableView.endUpdates()
      } else {
        spot.tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
      }

      spot.prepareItems()
      spot.updateHeight() { completion?() }
      return
    } else if let cell = spot.tableView.cellForRow(at: indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }
    completion?()
  }

  /**
   - parameter indexes: An array of integers that you want to reload, default is nil
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(_ indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    spot.refreshIndexes()

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(index)
      }
    } else {
      for (index, _) in spot.component.items.enumerated() {
        spot.configureItem(index)
      }
    }

    if let indexes = indexes {
      spot.tableView.reload(indexes, animation: animation.tableViewAnimation)
    } else {
      animation != .none
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
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion closure that is run when the updates are finished
   */
  public func process(_ updates: [Int], withAnimation animation: SpotsAnimation = .automatic, completion: Completion) {
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
   Reload spot with ItemChanges

   - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter updateDataSource: A closure to update your data source
   - parameter completion:       A completion closure that runs when your updates are done
   */
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation = .automatic, updateDataSource: () -> Void, completion: Completion) {
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
