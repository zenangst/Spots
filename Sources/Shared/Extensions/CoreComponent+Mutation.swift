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
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.model.items.count
      weakSelf.model.items.append(item)

      if numberOfItems == 0 {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.updateHeight {
          weakSelf.afterUpdate()
          completion?()
        }
      } else {
        Dispatch.main {
          weakSelf.configureItem(at: numberOfItems, usesViewSize: true)
          weakSelf.userInterface?.insert([numberOfItems], withAnimation: animation, completion: nil)
          weakSelf.updateHeight {
            weakSelf.afterUpdate()
            weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self else {
        completion?()
        return
      }

      var indexes = [Int]()
      let numberOfItems = weakSelf.model.items.count

      weakSelf.model.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(numberOfItems + $0.offset)
        weakSelf.configureItem(at: numberOfItems + $0.offset, usesViewSize: true)
      }

      if numberOfItems > 0 {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
        weakSelf.updateHeight {
          completion?()
        }
      } else {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.updateHeight {
          weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.model.items.count
      var indexes = [Int]()

      weakSelf.model.items.insert(contentsOf: items, at: 0)

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
          weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self else {
        completion?()
        return
      }

      let numberOfItems = weakSelf.model.items.count
      var indexes = [Int]()

      weakSelf.model.items.insert(item, at: index)

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
        weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self,
        let index = weakSelf.model.items.index(where: { $0 == item }) else {
          completion?()
          return
      }

      weakSelf.model.items.remove(at: index)
      weakSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.view.superview?.layoutSubviews()
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
        weakSelf.model.items.remove(at: $0)
      }

      weakSelf.userInterface?.delete(indexPaths, withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.model.items.remove(at: index)
      weakSelf.userInterface?.delete([index], withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self else {
        completion?()
        return
      }

      indexes.sorted(by: { $0 > $1 }).forEach {
        weakSelf.model.items.remove(at: $0)
      }

      weakSelf.userInterface?.delete(indexes, withAnimation: animation, completion: nil)
      weakSelf.afterUpdate()
      weakSelf.sanitize {
        weakSelf.view.superview?.layoutSubviews()
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
      guard let weakSelf = self,
        let oldItem = weakSelf.item(at: index) else {
          completion?()
          return
      }

      weakSelf.items[index] = item

      if weakSelf.items[index].kind == "composite" {
        if let compositeView: Composable? = weakSelf.userInterface?.view(at: index) {
          let compositeComponents = weakSelf.compositeComponents.filter { $0.itemIndex == item.index }
          compositeView?.configure(&weakSelf.items[index],
                                   compositeComponents: compositeComponents)
        } else {
          for compositeSpot in weakSelf.compositeComponents {
            compositeSpot.component.setup(weakSelf.view.frame.size)
            compositeSpot.component.reload([])
          }
        }

        weakSelf.view.superview?.layoutSubviews()
        weakSelf.afterUpdate()
        completion?()
        return
      } else {
        weakSelf.configureItem(at: index, usesViewSize: true)
        let newItem = weakSelf.items[index]

        if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
          if let cell: ItemConfigurable = weakSelf.userInterface?.view(at: index), animation != .none {
            weakSelf.userInterface?.beginUpdates()
            cell.configure(&weakSelf.items[index])
            weakSelf.userInterface?.endUpdates()
          } else {
            weakSelf.userInterface?.reload([index], withAnimation: animation, completion: nil)
          }
          weakSelf.afterUpdate()
          weakSelf.updateHeight {
            weakSelf.view.superview?.layoutSubviews()
            completion?()
          }
          return
        } else if let cell: ItemConfigurable = weakSelf.userInterface?.view(at: index) {
          cell.configure(&weakSelf.items[index])
          weakSelf.view.superview?.layoutSubviews()
          completion?()
        } else {
          weakSelf.afterUpdate()
          weakSelf.view.superview?.layoutSubviews()
          completion?()
        }
      }
    }
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.refreshIndexes()

      Dispatch.main {
        guard let weakSelf = self else {
          completion?()
          return
        }

        if let indexes = indexes {
          indexes.forEach { index  in
            weakSelf.configureItem(at: index, usesViewSize: true)
          }
        } else {
          for (index, _) in weakSelf.model.items.enumerated() {
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
        weakSelf.view.superview?.layoutSubviews()
        completion?()
      }
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    userInterface?.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions, childUpdates: changes.updatedChildren), withAnimation: animation, updateDataSource: updateDataSource) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if changes.updates.isEmpty {
        weakSelf.process(changes.updatedChildren, withAnimation: animation) {
          weakSelf.layout(weakSelf.view.bounds.size)
          completion?()
        }
      } else {
        weakSelf.process(changes.updates, withAnimation: animation) {
          weakSelf.process(changes.updatedChildren, withAnimation: animation) {
            weakSelf.layout(weakSelf.view.bounds.size)
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

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reloadIfNeeded(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if weakSelf.items == items {
        Dispatch.main {
          weakSelf.cache()
          completion?()
          weakSelf.view.superview?.layoutSubviews()
        }
        return
      }

      Dispatch.main { [weak self] in
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
          weakSelf.updateHeight {
            weakSelf.afterUpdate()
            weakSelf.cache()
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
      guard let weakSelf = self else {
        return
      }

      let newComponentModel = ComponentModel(json)

      guard weakSelf.model != newComponentModel else {
        weakSelf.cache()
        return
      }

      weakSelf.model = newComponentModel
      weakSelf.reload(nil, withAnimation: animation) { [weak self] in
        guard let weakSelf = self else {
          return
        }
        weakSelf.afterUpdate()
        weakSelf.view.superview?.layoutSubviews()
        weakSelf.cache()
      }
    }
  }
}
