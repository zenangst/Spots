#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Brick

// MARK: - Spotable extension
public extension Spotable {

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.component.items.count
      weakSelf.component.items.append(item)

      if numberOfItems == 0 {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.updateHeight() {
          weakSelf.afterUpdate()
          completion?()
        }
      } else {
        Dispatch.mainQueue {
          weakSelf.configureItem(at: numberOfItems, usesViewSize: true)
          weakSelf.userInterface?.insert([numberOfItems], withAnimation: animation, completion: nil)
          weakSelf.updateHeight() {
            weakSelf.afterUpdate()
            weakSelf.render().superview?.layoutSubviews()
            completion?()
          }
        }
      }
    }
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      var indexes = [Int]()
      let numberOfItems = weakSelf.component.items.count

      weakSelf.component.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(numberOfItems + $0.offset)
        weakSelf.configureItem(at: numberOfItems + $0.offset, usesViewSize: true)
      }

      if numberOfItems > 0 {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
        weakSelf.updateHeight() {
          completion?()
        }
      } else {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.updateHeight() {
          weakSelf.render().superview?.layoutSubviews()
          completion?()
        }
      }
    }
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func prepend(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.component.items.count
      var indexes = [Int]()

      weakSelf.component.items.insert(contentsOf: items, at: 0)

      items.enumerated().forEach {
        if numberOfItems > 0 {
          indexes.append(items.count - 1 - $0.offset)
        }
        weakSelf.configureItem(at: $0.offset, usesViewSize: true)
      }

      if !indexes.isEmpty {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation) {
          weakSelf.afterUpdate()
          weakSelf.sanitize {
            completion?()
          }
        }
      } else {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.afterUpdate()
        weakSelf.sanitize {
          weakSelf.render().superview?.layoutSubviews()
          completion?()
        }
      }
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func insert(_ item: Item, index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.component.items.count
      var indexes = [Int]()

      weakSelf.component.items.insert(item, at: index)

      if numberOfItems > 0 {
        indexes.append(index)
      }

      if numberOfItems > 0 {
        weakSelf.configureItem(at: numberOfItems, usesViewSize: true)
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
      } else {
        weakSelf.userInterface?.reloadDataSource()
      }
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self,
        let index = weakSelf.component.items.index(where: { $0 == item }) else {
          completion?()
          return
      }

      weakSelf.component.items.remove(at: index)
      weakSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      var indexPaths = [Int]()
      var indexes = [Int]()

      for (index, _) in items.enumerated() {
        indexPaths.append(index)
        indexes.append(index)
      }

      indexes.sorted(by: { $0 > $1 }).forEach {
        weakSelf.component.items.remove(at: $0)
      }

      weakSelf.userInterface?.delete(indexPaths, withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.component.items.remove(at: index)
      weakSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      indexes.sorted(by: { $0 > $1 }).forEach {
        weakSelf.component.items.remove(at: $0)
      }

      weakSelf.userInterface?.delete(indexes, withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.render().superview?.layoutSubviews()
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
  func update(_ item: Item, index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self,
        let oldItem = weakSelf.item(at: index) else {
          completion?()
          return
      }

      weakSelf.items[index] = item
      weakSelf.configureItem(at: index, usesViewSize: true)

      let newItem = weakSelf.items[index]

      #if !os(OSX)
        if let composite: Composable = weakSelf.userInterface?.view(at: index),
          let spots = weakSelf.spotsCompositeDelegate?.resolve(index, itemIndex: index) {
          weakSelf.userInterface?.beginUpdates()
          composite.configure(&weakSelf.component.items[index], spots: spots)
          weakSelf.userInterface?.endUpdates()
          weakSelf.updateHeight() {
            weakSelf.render().superview?.layoutSubviews()
            completion?()
          }
          return
        }
      #endif

      if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
        if let cell: SpotConfigurable = weakSelf.userInterface?.view(at: index), animation != .none {
          weakSelf.userInterface?.beginUpdates()
          cell.configure(&weakSelf.items[index])
          weakSelf.userInterface?.endUpdates()
        } else {
          weakSelf.userInterface?.reload([index], withAnimation: animation, completion: nil)
        }
        weakSelf.afterUpdate()
        weakSelf.updateHeight {
          weakSelf.render().superview?.layoutSubviews()
          completion?()
        }
        return
      } else if let cell: SpotConfigurable = weakSelf.userInterface?.view(at: index) {
        cell.configure(&weakSelf.items[index])
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      } else {
        weakSelf.afterUpdate()
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.refreshIndexes()

      Dispatch.mainQueue {
        guard let weakSelf = self else {
          completion?()
          return
        }

        if let indexes = indexes {
          indexes.forEach { index  in
            weakSelf.configureItem(at: index, usesViewSize: true)
          }
        } else {
          for (index, _) in weakSelf.component.items.enumerated() {
            weakSelf.configureItem(at: index, usesViewSize: true)
          }
        }

        if let indexes = indexes {
          weakSelf.userInterface?.reload(indexes, withAnimation: animation, completion: completion)
          return
        } else {
          if animation != .none {
            weakSelf.userInterface?.reloadSection(0, withAnimation: animation, completion: completion)
            return
          } else {
            weakSelf.userInterface?.reloadDataSource()
          }
        }
        weakSelf.render().superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    reloadIfNeeded(changes,
                   withAnimation: animation,
                   updateDataSource: updateDataSource,
                   completion: completion)
  }

  /// A collection of view models
  var items: [Item] {
    set(items) {
      component.items = items
    }
    get {
      return component.items
    }
  }

  /// Return a dictionary representation of Spotable object
  public var dictionary: [String : Any] {
    get {
      return component.dictionary
    }
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reloadIfNeeded(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if weakSelf.items == items {
        Dispatch.mainQueue {
          weakSelf.cache()
          completion?()
          weakSelf.render().superview?.layoutSubviews()
        }
        return
      }

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else {
          completion?()
          return
        }

        var indexes: [Int]? = nil
        let oldItems = weakSelf.items
        weakSelf.items = items

        if items.count == oldItems.count {
          for (index, item) in items.enumerated() {
            guard !(item == oldItems[index]) else {
              weakSelf.items[index].size = oldItems[index].size
              continue
            }

            if indexes == nil { indexes = [Int]() }
            indexes?.append(index)
          }
        }

        weakSelf.reload(indexes, withAnimation: animation) {
          weakSelf.updateHeight() {
            weakSelf.afterUpdate()
            weakSelf.cache()
            completion?()
          }
        }
      }
    }
  }

  /// Reload Spotable object with JSON if contents changed
  ///
  /// - parameter json:      A JSON dictionary
  /// - parameter animation:  A Animation that is used when performing the mutation (only works for Listable objects)
  public func reloadIfNeeded(_ json: [String : Any], withAnimation animation: Animation = .automatic) {
    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else {
        return
      }

      let newComponent = Component(json)

      guard weakSelf.component != newComponent else {
        weakSelf.cache()
        return
      }

      weakSelf.component = newComponent
      weakSelf.reload(nil, withAnimation: animation) { [weak self] in
        guard let weakSelf = self else {
          return
        }
        weakSelf.afterUpdate()
        weakSelf.render().superview?.layoutSubviews()
        weakSelf.cache()
      }
    }
  }
}
