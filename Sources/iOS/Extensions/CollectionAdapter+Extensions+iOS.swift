import UIKit
import Brick

public extension CollectionAdapter {

  public func ui<T>(at index: Int) -> T? {
    return spot.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? T
  }

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ item: Item, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in spot.items.enumerated() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: nil)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ items: [Item], withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in items.enumerated() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)

      spot.configureItem(at: itemsCount + index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: nil)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    spot.component.items.insert(item, at: index)
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    indexes.append(index)

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: nil)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func prepend(_ items: [Item], withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      indexes.append(items.count - 1 - $0.offset)
      spot.configureItem(at: $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      weakSelf.spot.collectionView.insert(indexes) {
        weakSelf.spot.updateHeight() {
          completion?()
        }
      }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ item: Item, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    guard let index = spot.component.items.index(where: { $0 == item })
      else { completion?(); return }

    perform(animation, withIndex: index) { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if animation == .none { UIView.setAnimationsEnabled(false) }
      weakSelf.spot.component.items.remove(at: index)
      weakSelf.spot.collectionView.delete([index], completion: nil)
      if animation == .none { UIView.setAnimationsEnabled(true) }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ items: [Item], withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    for (index, _) in items.enumerated() {
      indexes.append(count + index)
      spot.component.items.remove(at: count - index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }
      weakSelf.spot.collectionView.delete(indexes) {
        weakSelf.spot.updateHeight() {
          completion?()
        }
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ index: Int, withAnimation animation: SpotsAnimation = .none, completion: Completion) {
    perform(animation, withIndex: index) {
      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion?(); return }

        if animation == .none { UIView.setAnimationsEnabled(false) }
        weakSelf.spot.component.items.remove(at: index)
        weakSelf.spot.collectionView.delete([index], completion: nil)
        if animation == .none { UIView.setAnimationsEnabled(true) }
        weakSelf.spot.updateHeight() {
          completion?()
        }
      }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation = .none, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spot.collectionView.delete(indexes) {
        weakSelf.spot.updateHeight() {
          completion?()
        }
      }
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .none, completion: Completion = nil) {
    guard let oldItem = spot.item(at: index) else { completion?(); return }

    spot.items[index] = item
    spot.configureItem(at: index)

    let newItem = spot.items[index]
    let indexPath = IndexPath(item: index, section: 0)

    if let composite = spot.collectionView.cellForItem(at: indexPath) as? Composable {
      if let spots = spot.spotsCompositeDelegate?.resolve(spot.index, itemIndex: (indexPath as NSIndexPath).item) {
        spot.collectionView.performBatchUpdates({
          composite.configure(&self.spot.component.items[indexPath.item], spots: spots)
          }, completion: nil)
          completion?()
        return
      }
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.collectionView.cellForItem(at: indexPath) as? SpotConfigurable {
        if animation != .none {
          spot.collectionView.performBatchUpdates({
            }, completion: { (_) in })
        }
        cell.configure(&self.spot.items[index])
      }
    } else if let cell = spot.collectionView.cellForItem(at: indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }

    completion?()
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  public func process(_ updates: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    guard !updates.isEmpty else {
      completion?()
      return
    }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.spot.item(at: index) else { completion?(); continue }
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
  /// - parameter animation:        A SpotAnimation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    spot.collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {
      if changes.updates.isEmpty {
        self.process(changes.updatedChildren, withAnimation: animation) {
          self.spot.layout(self.spot.collectionView.bounds.size)
          completion?()
        }
      } else {
        self.process(changes.updates, withAnimation: animation) {
          self.process(changes.updatedChildren, withAnimation: animation) {
            self.spot.layout(self.spot.collectionView.bounds.size)
            completion?()
          }
        }
      }
    }
  }

  /// Reload with indexes
  ///
  /// - parameter indexes:    An array of integers that you want to reload, default is nil.
  /// - parameter animation:  Perform reload animation.
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded.
  public func reload(_ indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .none, completion: Completion) {
    if animation == .none { UIView.setAnimationsEnabled(false) }

    spot.refreshIndexes()
    var cellCache: [String : SpotConfigurable] = [:]

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(at: index)
      }
    } else {
      spot.component.items.enumerated().forEach { index, _  in
        spot.configureItem(at: index)
      }
    }

    cellCache.removeAll()

    if let indexes = indexes {
      spot.collectionView.reload(indexes)
    } else {
      spot.collectionView.reloadData()
    }

    spot.setup(spot.collectionView.bounds.size)
    spot.collectionView.layoutIfNeeded()
    completion?()

    if animation == .none { UIView.setAnimationsEnabled(true) }
  }
}
