#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Brick

// MARK: - Spotable extension
public extension Spotable {

  /// A computed value for the current index
  public var index: Int {
    return component.index
  }

  /// A computed CGFloat of the total height of all items inside of a component
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    var height: CGFloat = 0
    component.items.forEach {
      height += $0.size.height
    }

    return height
  }

  /// A helper method to return self as a Spotable type.
  ///
  /// - returns: Self as a Spotable type
  public var type: Spotable.Type {
    return type(of: self)
  }

  /// Resolve a UI component at index with inferred type
  ///
  /// - parameter index: The index of the UI component
  ///
  /// - returns: An optional view of inferred type
  public func ui<T>(at index: Int) -> T? {
    return userInterface?.view(at: index)
  }

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
        weakSelf.afterUpdate()
        completion?()
      } else {
        weakSelf.userInterface?.insert([itemsCount], withAnimation: animation, completion: nil)
        weakSelf.afterUpdate()
        completion?()
      }

      weakSelf.updateHeight()
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
      let itemsCount = weakSelf.component.items.count

      if weakSelf.component.items.isEmpty {
        weakSelf.component.items.append(contentsOf: items)
      } else {
        for (index, item) in items.enumerated() {
          weakSelf.component.items.append(item)
          indexes.append(itemsCount + index)

          weakSelf.configureItem(at: itemsCount + index)
        }
      }

      if itemsCount > 0 {
        weakSelf.userInterface?.insert(indexes, withAnimation: animation, completion: nil)
      } else {
        weakSelf.userInterface?.reloadDataSource()
      }
      weakSelf.updateHeight() {
        weakSelf.afterUpdate()
        completion?()
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
    guard let oldItem = self.item(at: index) else { completion?(); return }

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
      updateHeight() { completion?() }
      return
    } else if let cell: SpotConfigurable = userInterface?.view(at: index) {
      cell.configure(&items[index])
      afterUpdate()
      updateHeight() { completion?() }
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

  /// Prepare items in component
  func prepareItems() {
    component.items = prepare(items: component.items)
  }

  func prepare(items: [Item]) -> [Item] {
    var preparedItems = items
    preparedItems.enumerated().forEach { (index: Int, item: Item) in
      if let configuredItem = configure(item: item, at: index, usesViewSize: true) {
        preparedItems[index].index = index
        preparedItems[index] = configuredItem
      }
      if component.span > 0.0 {
        #if os(OSX)
          if let gridable = self as? Gridable,
            let layout = gridable.layout as? FlowLayout {
            preparedItems[index].size.width = gridable.collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
          }
        #else
          var spotWidth = render().frame.size.width

          if spotWidth == 0.0 {
            spotWidth = UIScreen.main.bounds.width
          }

          let newWidth = spotWidth / CGFloat(component.span)
          preparedItems[index].size.width = newWidth
        #endif
      }
    }

    return preparedItems
  }

  /// Resolve item at index.
  ///
  /// - parameter index: The index of the item that should be resolved.
  ///
  /// - returns: An optional Item that corresponds to the index.
  public func item(at index: Int) -> Item? {
    guard index < component.items.count && index > -1 else { return nil }
    return component.items[index]
  }

  /// Resolve item at index path.
  ///
  /// - parameter indexPath: The index path of the item that should be resolved.
  ///
  /// - returns: An optional Item that corresponds to the index path.
  public func item(at indexPath: IndexPath) -> Item? {
    #if os(OSX)
      return item(at: indexPath.item)
    #else
      return item(at: indexPath.row)
    #endif
  }


  /// Update the height of the UI Component
  ///
  /// - parameter completion: A completion closure that will be run in the main queue when the size has been updated.
  public func updateHeight(_ completion: Completion = nil) {
    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else { Dispatch.mainQueue { completion?(); }; return }
      let spotHeight = weakSelf.computedHeight
      Dispatch.mainQueue { [weak self] in
        self?.render().frame.size.height = spotHeight
        completion?()
      }
    }
  }

  /// Refresh indexes for all items to ensure that the indexes are unique and in ascending order.
  public func refreshIndexes(completion: Completion = nil) {
    var updatedItems  = items
    updatedItems.enumerated().forEach {
      updatedItems[$0.offset].index = $0.offset
    }

    items = updatedItems
    completion?()
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

    guard component != newComponent else { cache(); return }

    component = newComponent
    reload(nil, withAnimation: animation) { [weak self] in
      self?.cache()
    }
  }

  /// Caches the current state of the spot
  public func cache() {
    stateCache?.save(dictionary)
  }

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  public func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat {
    return 0.0
  }

  /// Prepares a view model item before being used by the UI component
  ///
  /// - parameter index:        The index of the view model
  /// - parameter usesViewSize: A boolean value to determine if the view uses the views height
  public func configureItem(at index: Int, usesViewSize: Bool = false) {
    guard let item = item(at: index),
      let configuredItem = configure(item: item, at: index, usesViewSize: usesViewSize) else { return }

    component.items[index] = configuredItem
  }

  func configure(item: Item, at index: Int, usesViewSize: Bool = false) -> Item? {
    var item = item
    item.index = index

    let kind = item.kind.isEmpty || Self.views.storage[item.kind] == nil
      ? Self.views.defaultIdentifier
      : item.kind

    guard let (_, resolvedView) = Self.views.make(kind),
      let view = resolvedView else { return nil }

    #if !os(OSX)
      if let composite = view as? Composable {
        let spots = composite.parse(item)

        spots.forEach { $0.registerAndPrepare() }

        if spotsCompositeDelegate?.compositeSpots[component.index] == nil {
          spotsCompositeDelegate?.compositeSpots[component.index] = [index : spots]
        } else {
          spotsCompositeDelegate?.compositeSpots[component.index]?[index] = spots
        }
      } else {
        // Set initial size for view
        view.frame.size = render().frame.size

        if view.frame.size == CGSize.zero {
          view.frame.size = UIScreen.main.bounds.size
        }

        (view as? UITableViewCell)?.contentView.frame = view.bounds
        (view as? UICollectionViewCell)?.contentView.frame = view.bounds
        (view as? SpotConfigurable)?.configure(&item)
      }
    #else
      view.frame.size.width = render().frame.size.width
      (view as? SpotConfigurable)?.configure(&item)
    #endif

    if let itemView = view as? SpotConfigurable, usesViewSize {
      setFallbackViewSize(to: &item, with: itemView)
    }

    if index < component.items.count && index > -1 {
      #if !os(OSX)
        if self is Gridable && (component.span > 0.0 || item.size.width == 0) {
          item.size.width = UIScreen.main.bounds.width / CGFloat(component.span)
        }
      #endif
    }

    return item
  }

  /// Set fallback size to view
  ///
  /// - Parameters:
  ///   - item: The item struct that is being configured.
  ///   - view: The view used for fallback size for the item.
  private func setFallbackViewSize(to item: inout Item, with view: SpotConfigurable) {
    if item.size.height == 0.0 {
      item.size.height = view.preferredViewSize.height
    }

    if item.size.width  == 0.0 {
      item.size.width  = view.preferredViewSize.width
    }

    if let superview = render().superview, item.size.width == 0.0 {
      item.size.width = superview.frame.width
    }

    if let view = view as? View, item.size.width  == 0.0 {
      item.size.width = view.bounds.width
    }
  }

  /// Update and return the size for the item at index path.
  ///
  /// - parameter indexPath: indexPath: An NSIndexPath.
  ///
  /// - returns: CGSize of the item at index path.
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return render().frame.size
  }


  /// Get identifier for item at index path
  ///
  /// - parameter indexPath: The index path for the item
  ///
  /// - returns: The identifier string of the item at index path
  func identifier(at indexPath: IndexPath) -> String {
    #if os(OSX)
      return identifier(at: indexPath.item)
    #else
      return identifier(at: indexPath.row)
    #endif
  }


  /// Lookup identifier at index.
  ///
  /// - parameter index: The index of the item that needs resolving.
  ///
  /// - returns: A string identifier for the view, defaults to the `defaultIdentifier` on the Spotable object.
  public func identifier(at index: Int) -> String {
    guard let item = item(at: index), type.views.storage[item.kind] != nil
      else {
        return type.views.defaultIdentifier
    }

    return item.kind
  }


  /// Register and prepare all items in the Spotable object.
  func registerAndPrepare() {
    register()
    prepareItems()
  }


  /// Update height and refresh indexes for the Spotable object.
  ///
  /// - parameter completion: A completion closure that will be run when the computations are complete.
  public func sanitize(completion: Completion = nil) {
    updateHeight() { [weak self] in
      self?.refreshIndexes()
      completion?()
    }
  }

  /// Register default view for the Spotable object
  ///
  /// - parameter view: The view type that should be used as the default view
  func registerDefault(view: View.Type) {
    if type(of: self).views.storage[type(of: self).views.defaultIdentifier] == nil {
      type(of: self).views.defaultItem = Registry.Item.classType(view)
    }
  }


  /// Register a composite view for the Spotable component.
  ///
  /// - parameter view: The view type that should be used as the composite view for the Spotable object.
  func registerComposite(view: View.Type) {
    if type(of: self).views.composite == nil {
      type(of: self).views.composite = Registry.Item.classType(view)
    }
  }


  /// Register a nib file with identifier on the Spotable object.
  ///
  /// - parameter nib:        A Nib file that should be used for identifier
  /// - parameter identifier: A StringConvertible identifier for the registered nib.
  public static func register(nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }


  /// Register a view with an identifier
  ///
  /// - parameter view:       The view type that should be registered with an identifier.
  /// - parameter identifier: A StringConvertible identifier for the registered view type.
  public static func register(view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }


  /// Register a default view for the Spotable object.
  ///
  /// - parameter view: The view type that should be used as the default view for the Spotable object.
  public static func register(defaultView view: View.Type) {
    self.views.defaultItem = Registry.Item.classType(view)
  }

  public func beforeUpdate() {}
  public func afterUpdate() {}
}
