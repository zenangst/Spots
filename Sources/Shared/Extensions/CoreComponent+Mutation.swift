#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

// MARK: - CoreComponent extension
public extension CoreComponent {

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let numberOfItems = strongSelf.model.items.count
      strongSelf.model.items.append(item)

      if numberOfItems == 0 {
        strongSelf.userInterface?.reloadDataSource()
        strongSelf.updateHeight {
          strongSelf.afterUpdate()
          completion?()
        }
      } else {
        Dispatch.main {
          strongSelf.configureItem(at: numberOfItems, usesViewSize: true)
          strongSelf.userInterface?.insert([numberOfItems], withAnimation: animation, completion: nil)
          strongSelf.updateHeight {
            strongSelf.afterUpdate()
            strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      var indexes = [Int]()
      let numberOfItems = strongSelf.model.items.count

      strongSelf.model.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(numberOfItems + $0.offset)
        strongSelf.configureItem(at: numberOfItems + $0.offset, usesViewSize: true)
      }

      if numberOfItems > 0 {
        strongSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
        strongSelf.updateHeight {
          completion?()
        }
      } else {
        strongSelf.userInterface?.reloadDataSource()
        strongSelf.updateHeight {
          strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let numberOfItems = strongSelf.model.items.count
      var indexes = [Int]()

      strongSelf.model.items.insert(contentsOf: items, at: 0)

      items.enumerated().forEach {
        if numberOfItems > 0 {
          indexes.append(items.count - 1 - $0.offset)
        }
        strongSelf.configureItem(at: $0.offset, usesViewSize: true)
      }

      if !indexes.isEmpty {
        strongSelf.userInterface?.insert(indexes, withAnimation: animation) {
          strongSelf.afterUpdate()
          strongSelf.sanitize {
            completion?()
          }
        }
      } else {
        strongSelf.userInterface?.reloadDataSource()
        strongSelf.afterUpdate()
        strongSelf.sanitize {
          strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let numberOfItems = strongSelf.model.items.count
      var indexes = [Int]()

      strongSelf.model.items.insert(item, at: index)

      if numberOfItems > 0 {
        indexes.append(index)
      }

      if numberOfItems > 0 {
        strongSelf.configureItem(at: numberOfItems, usesViewSize: true)
        strongSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
      } else {
        strongSelf.userInterface?.reloadDataSource()
      }
      strongSelf.afterUpdate()
      strongSelf.sanitize {
        strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self,
        let index = strongSelf.model.items.index(where: { $0 == item }) else {
          completion?()
          return
      }

      strongSelf.model.items.remove(at: index)
      strongSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      strongSelf.afterUpdate()
      strongSelf.sanitize {
        strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
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
        strongSelf.model.items.remove(at: $0)
      }

      strongSelf.userInterface?.delete(indexPaths, withAnimation: animation, completion: nil)
      strongSelf.afterUpdate()
      strongSelf.sanitize {
        strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      strongSelf.model.items.remove(at: index)
      strongSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      strongSelf.afterUpdate()
      strongSelf.sanitize {
        strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      indexes.sorted(by: { $0 > $1 }).forEach {
        strongSelf.model.items.remove(at: $0)
      }

      strongSelf.userInterface?.delete(indexes, withAnimation: animation, completion: nil)
      strongSelf.afterUpdate()
      strongSelf.sanitize {
        strongSelf.view.superview?.layoutSubviews()
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
    Dispatch.main { [weak self] in
      guard let strongSelf = self,
        let oldItem = strongSelf.item(at: index) else {
          completion?()
          return
      }

      strongSelf.items[index] = item

      if strongSelf.items[index].kind == "composite" {
        if let compositeView: Composable? = strongSelf.userInterface?.view(at: index) {
          let compositeComponents = strongSelf.compositeComponents.filter { $0.itemIndex == item.index }
          compositeView?.configure(&strongSelf.items[index],
                                   compositeComponents: compositeComponents)
        } else {
          for compositeSpot in strongSelf.compositeComponents {
            compositeSpot.component.setup(strongSelf.view.frame.size)
            compositeSpot.component.reload([])
          }
        }

        strongSelf.view.superview?.layoutSubviews()
        strongSelf.afterUpdate()
        completion?()
        return
      } else {
        strongSelf.configureItem(at: index, usesViewSize: true)
        let newItem = strongSelf.items[index]

        if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
          if let cell: ItemConfigurable = strongSelf.userInterface?.view(at: index), animation != .none {
            strongSelf.userInterface?.beginUpdates()
            cell.configure(&strongSelf.items[index])
            strongSelf.userInterface?.endUpdates()
          } else {
            strongSelf.userInterface?.reload([index], withAnimation: animation, completion: nil)
          }
          strongSelf.afterUpdate()
          strongSelf.updateHeight {
            strongSelf.view.superview?.layoutSubviews()
            completion?()
          }
          return
        } else if let cell: ItemConfigurable = strongSelf.userInterface?.view(at: index) {
          cell.configure(&strongSelf.items[index])
          strongSelf.view.superview?.layoutSubviews()
          completion?()
        } else {
          strongSelf.afterUpdate()
          strongSelf.view.superview?.layoutSubviews()
          completion?()
        }
      }
    }
  }

  /// Reloads a component only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      strongSelf.refreshIndexes()

      Dispatch.main {
        guard let strongSelf = self else {
          completion?()
          return
        }

        if let indexes = indexes {
          indexes.forEach { index  in
            strongSelf.configureItem(at: index, usesViewSize: true)
          }
        } else {
          for (index, _) in strongSelf.model.items.enumerated() {
            strongSelf.configureItem(at: index, usesViewSize: true)
          }
        }

        if let indexes = indexes {
          strongSelf.userInterface?.reload(indexes, withAnimation: animation, completion: completion)
          return
        } else {
          if animation != .none {
            strongSelf.userInterface?.reloadSection(0, withAnimation: animation, completion: completion)
            return
          } else {
            strongSelf.userInterface?.reloadDataSource()
          }
        }
        strongSelf.view.superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Reload component with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    userInterface?.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions, childUpdates: changes.updatedChildren), withAnimation: animation, updateDataSource: updateDataSource) { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      if changes.updates.isEmpty {
        strongSelf.process(changes.updatedChildren, withAnimation: animation) {
          strongSelf.layout(strongSelf.view.bounds.size)
          completion?()
        }
      } else {
        strongSelf.process(changes.updates, withAnimation: animation) {
          strongSelf.process(changes.updatedChildren, withAnimation: animation) {
            strongSelf.layout(strongSelf.view.bounds.size)
            completion?()
          }
        }
      }
    }
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter animation:  A Animation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  public func process(_ updates: [Int], withAnimation animation: Animation, completion: Completion) {
    guard !updates.isEmpty else {
      completion?()
      return
    }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.item(at: index) else {
        continue
      }

      update(item, index: index, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /// A collection of view models
  var items: [Item] {
    set(items) {
      model.items = items
    }
    get {
      return model.items
    }
  }

  /// Return a dictionary representation of CoreComponent object
  public var dictionary: [String : Any] {
    return model.dictionary
  }

  /// Reloads a component only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reloadIfNeeded(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      if strongSelf.items == items {
        Dispatch.main {
          strongSelf.cache()
          completion?()
          strongSelf.view.superview?.layoutSubviews()
        }
        return
      }

      Dispatch.main { [weak self] in
        guard let strongSelf = self else {
          completion?()
          return
        }

        var indexes: [Int]? = nil
        let oldItems = strongSelf.items
        strongSelf.items = items

        if items.count == oldItems.count {
          for (index, item) in items.enumerated() {
            guard !(item == oldItems[index]) else {
              strongSelf.items[index].size = oldItems[index].size
              continue
            }

            if indexes == nil { indexes = [Int]() }
            indexes?.append(index)
          }
        }

        strongSelf.reload(indexes, withAnimation: animation) {
          strongSelf.updateHeight {
            strongSelf.afterUpdate()
            strongSelf.cache()
            completion?()
          }
        }
      }
    }
  }

  /// Reload CoreComponent object with JSON if contents changed
  ///
  /// - parameter json:      A JSON dictionary
  /// - parameter animation:  A Animation that is used when performing the mutation (only works for Listable objects)
  public func reloadIfNeeded(_ json: [String : Any], withAnimation animation: Animation = .automatic) {
    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        return
      }

      let newComponentModel = ComponentModel(json)

      guard strongSelf.model != newComponentModel else {
        strongSelf.cache()
        return
      }

      strongSelf.model = newComponentModel
      strongSelf.reload(nil, withAnimation: animation) { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.afterUpdate()
        strongSelf.view.superview?.layoutSubviews()
        strongSelf.cache()
      }
    }
  }
}
