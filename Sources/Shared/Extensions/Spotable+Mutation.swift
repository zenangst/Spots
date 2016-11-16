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

      let itemsCount = weakSelf.component.items.count
      weakSelf.component.items.append(item)

      if itemsCount == 0 {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.updateHeight() {
          weakSelf.afterUpdate()
          completion?()
        }
      } else {
        weakSelf.userInterface?.insert([itemsCount], withAnimation: animation, completion: nil)
        weakSelf.updateHeight() {
          weakSelf.afterUpdate()
          completion?()
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
      let count = weakSelf.component.items.count

      weakSelf.component.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(count + $0.offset)
        weakSelf.configureItem(at: count + $0.offset)
      }

      Dispatch.mainQueue { [weak self] in
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
        weakSelf.updateHeight() {
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
    let itemsCount = component.items.count
    var indexes = [Int]()

    component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      if itemsCount > 0 {
        indexes.append(items.count - 1 - $0.offset)
      }
      configureItem(at: $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if !indexes.isEmpty {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation) {
          weakSelf.afterUpdate()
          weakSelf.sanitize { completion?() }
        }
      } else {
        weakSelf.userInterface?.reloadDataSource()
        weakSelf.afterUpdate()
        weakSelf.sanitize { completion?() }
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
    let itemsCount = component.items.count
    component.items.insert(item, at: index)
    var indexes = [Int]()

    if itemsCount > 0 {
      indexes.append(index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
      } else {
        weakSelf.userInterface?.reloadDataSource()
      }
      weakSelf.afterUpdate()
      weakSelf.sanitize { completion?() }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: Item, withAnimation animation: Animation = .automatic, completion: Completion) {
    guard let index = component.items.index(where: { $0 == item })
      else { completion?(); return }

    component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      self?.userInterface?.delete([index], withAnimation: animation, completion: nil)
      self?.afterUpdate()
      self?.sanitize { completion?() }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    var indexes = [Int]()

    for (index, _) in items.enumerated() {
      indexPaths.append(index)
      indexes.append(index)
    }

    indexes.sorted(by: { $0 > $1 }).forEach { component.items.remove(at: $0) }

    Dispatch.mainQueue { [weak self] in
      self?.userInterface?.delete(indexPaths, withAnimation: animation, completion: nil)
      self?.afterUpdate()
      self?.sanitize { completion?() }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      self?.component.items.remove(at: index)
      self?.userInterface?.delete([index], withAnimation: animation, completion: nil)
      self?.afterUpdate()
      self?.sanitize { completion?() }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      indexes.sorted(by: { $0 > $1 }).forEach { self?.component.items.remove(at: $0) }
      self?.userInterface?.delete(indexes, withAnimation: animation, completion: nil)
      self?.afterUpdate()
      self?.sanitize { completion?() }
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func update(_ item: Item, index: Int, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let oldItem = self.item(at: index) else {
      completion?()
      return
    }

    items[index] = item
    configureItem(at: index)

    let newItem = items[index]

    #if !os(OSX)
      if let composite: Composable = userInterface?.view(at: index),
        let spots = spotsCompositeDelegate?.resolve(index, itemIndex: index) {
        userInterface?.beginUpdates()
        composite.configure(&component.items[index], spots: spots)
        userInterface?.endUpdates()
        updateHeight() {
          completion?()
        }
        return
      }
    #endif

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell: SpotConfigurable = userInterface?.view(at: index), animation != .none {
        userInterface?.beginUpdates()
        cell.configure(&items[index])
        userInterface?.endUpdates()
      } else {
        userInterface?.reload([index], withAnimation: animation, completion: nil)
      }
      afterUpdate()
      updateHeight {
        completion?()
      }
      return
    } else if let cell: SpotConfigurable = userInterface?.view(at: index) {
      cell.configure(&items[index])
      afterUpdate()
      completion?()
    } else {
      afterUpdate()
      completion?()
    }
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
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
      userInterface?.reload(indexes, withAnimation: animation, completion: nil)
    } else {
      animation != .none
        ? userInterface?.reloadSection(0, withAnimation: animation, completion: nil)
        : userInterface?.reloadDataSource()
    }

    afterUpdate()
    updateHeight() {
      completion?()
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    reloadIfNeeded(changes, withAnimation: animation, updateDataSource: updateDataSource, completion: completion)
  }

  /// A collection of view models
  var items: [Item] {
    set(items) {
      component.items = items
    }
    get { return component.items }
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
    guard !(self.items == items) else {
      cache()
      return
    }

    var indexes: [Int]? = nil
    let oldItems = self.items
    self.items = items

    if items.count == oldItems.count {
      for (index, item) in items.enumerated() {
        guard !(item == oldItems[index]) else { continue }

        if indexes == nil { indexes = [Int]() }
        indexes?.append(index)
      }
    }

    reload(indexes, withAnimation: animation) {
      self.cache()
      completion?()
    }
  }

  /// Reload Spotable object with JSON if contents changed
  ///
  /// - parameter json:      A JSON dictionary
  /// - parameter animation:  A Animation that is used when performing the mutation (only works for Listable objects)
  public func reloadIfNeeded(_ json: [String : Any], withAnimation animation: Animation = .automatic) {
    let newComponent = Component(json)

    guard component != newComponent else {
      cache()
      return
    }

    component = newComponent
    reload(nil, withAnimation: animation) { [weak self] in
      self?.cache()
    }
  }
}
