import UIKit
import Brick
import Sugar

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject, SpotAdapter {
  // An unowned Gridable object
  unowned var spot: Gridable

  /**
   Initialization a new instance of a CollectionAdapter using a Gridable object

   - Parameter spot: A Gridable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in spot.items.enumerate() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter items: A collection of view models that you want to insert
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in items.enumerate() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)

      spot.configureItem(itemsCount + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot.component.items.insert(item, atIndex: index)
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    indexes.append(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
      }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter items: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
      spot.configureItem($0.index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      weakSelf.spot.collectionView.insert(indexes, completion: completion)
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    perform(animation, withIndex: index) { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if animation == .None { UIView.setAnimationsEnabled(false) }
      weakSelf.spot.component.items.removeAtIndex(index)
      weakSelf.spot.collectionView.delete([index], completion: completion)
      if animation == .None { UIView.setAnimationsEnabled(true) }
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter items: A collection of view models that you want to delete
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    for (index, _) in items.enumerate() {
      indexes.append(count + index)
      spot.component.items.removeAtIndex(count - index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { completion?(); return }
      weakSelf.spot.collectionView.delete(indexes, completion: completion)
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    perform(animation, withIndex: index) {
      dispatch { [weak self] in
        guard let weakSelf = self else { completion?(); return }

        if animation == .None { UIView.setAnimationsEnabled(false) }
        weakSelf.spot.component.items.removeAtIndex(index)
        weakSelf.spot.collectionView.delete([index], completion: completion)
        if animation == .None { UIView.setAnimationsEnabled(true) }
        weakSelf.spot.updateHeight() {
          completion?()
        }
      }
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spot.collectionView.delete(indexes, completion: completion)
      weakSelf.spot.updateHeight() {
        completion?()
      }
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let oldItem = spot.item(index) else { completion?(); return }

    spot.items[index] = item
    spot.configureItem(index)

    let newItem = spot.items[index]
    let indexPath = NSIndexPath(forItem: index, inSection: 0)

    if let composite = spot.collectionView.cellForItemAtIndexPath(indexPath) as? SpotComposable {
      if let spots = spot.spotsCompositeDelegate?.resolve(spotIndex: spot.index, itemIndex: indexPath.item) {
        spot.collectionView.performBatchUpdates({
          composite.configure(&self.spot.component.items[indexPath.item], spots: spots)
        }, completion: { (_) in
            completion?()
        })
        return
      }
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.collectionView.cellForItemAtIndexPath(indexPath) as? SpotConfigurable {
        spot.collectionView.performBatchUpdates({
          }, completion: { (_) in
            cell.configure(&self.spot.items[index])
        })
      } else {
        spot.collectionView.reload([index], section: 0)
      }
    } else if let cell = spot.collectionView.cellForItemAtIndexPath(indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }

    completion?()
  }

  public func reloadIfNeeded(changes: ViewModelChanges, updateDataSource: () -> Void, completion: Completion) {
    spot.collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {
      if changes.updates.isEmpty {
        guard !changes.updatedChildren.isEmpty else {
          completion?()
          return
        }

        for index in changes.updatedChildren {
          guard let item = self.spot.item(index) else { continue }
          self.spot.update(item, index: index, withAnimation: .Automatic) {
            if changes.updatedChildren.last == index {
              completion?()
            }
          }
        }

      } else {
        for index in changes.updates {
          guard let item = self.spot.item(index) else { continue }

          self.spot.update(item, index: index, withAnimation: .Automatic) {
            if changes.updates.last == index {
              guard !changes.updatedChildren.isEmpty else {
                completion?()
                return
              }

              for index in changes.updatedChildren {
                guard let item = self.spot.item(index) else { continue }
                self.spot.update(item, index: index, withAnimation: .Automatic) {
                  if changes.updatedChildren.last == index {
                    completion?()
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animation: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    spot.refreshIndexes()
    var cellCache: [String : SpotConfigurable] = [:]

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(index)
      }
    } else {
      spot.component.items.enumerate().forEach { index, _  in
        spot.configureItem(index)
      }
    }

    cellCache.removeAll()
    spot.collectionView.collectionViewLayout.invalidateLayout()

    if let indexes = indexes {
      spot.collectionView.reload(indexes)
    } else {
      spot.collectionView.reloadData()
    }

    spot.setup(spot.collectionView.bounds.size)
    spot.collectionView.layoutIfNeeded()
    completion?()
  }
}
