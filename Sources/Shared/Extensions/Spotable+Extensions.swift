#if os(iOS)
  import UIKit
#else
  import Foundation
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

    return component.items.reduce(0, { $0 + $1.size.height })
  }

  /// Resolve a UI component at index with inferred type
  ///
  /// - parameter index: The index of the UI component
  ///
  /// - returns: An optional view of inferred type
  public func ui<T>(atIndex index: Int) -> T? {
    return adapter?.ui(at: index)
  }

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func prepend(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: Item, withAnimation animation: SpotsAnimation = .automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A SpotAnimation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    adapter?.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: updateDataSource, completion: completion)
  }

  /// A collection of view models
  var items: [Item] {
    set(items) {
      component.items = items
      registerAndPrepare()
      updateHeight()
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
    component.items.enumerated().forEach { (index: Int, _) in
      configureItem(at: index, usesViewSize: true)
    }
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
  public func refreshIndexes() {
    var updatedItems  = items
    updatedItems.enumerated().forEach {
      updatedItems[$0.offset].index = $0.offset
    }

    items = updatedItems
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reloadIfNeeded(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
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
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (only works for Listable objects)
  public func reloadIfNeeded(_ json: [String : Any], withAnimation animation: SpotsAnimation = .automatic) {
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
    guard let item = item(at: index) else { return }

    var viewModel = item
    viewModel.index = index

    let kind = item.kind.isEmpty || Self.views.storage[item.kind] == nil
      ? Self.views.defaultIdentifier
      : viewModel.kind

    guard let (_, resolvedView) = Self.views.make(kind),
      let view = resolvedView else { return }

    #if !os(OSX)
      if let composite = view as? Composable {
        let spots = composite.parse(viewModel)

        spots.forEach { $0.registerAndPrepare() }

        if spotsCompositeDelegate?.compositeSpots[component.index] == nil {
          spotsCompositeDelegate?.compositeSpots[component.index] = [index : spots]
        } else {
          spotsCompositeDelegate?.compositeSpots[component.index]?[index] = spots
        }
      } else {
        // Set initial size for view
        view.frame.size = render().frame.size

        if let view = view as? UITableViewCell {
          view.contentView.frame = view.bounds
        }

        if let view = view as? UICollectionViewCell {
          view.contentView.frame = view.bounds
        }

        (view as? SpotConfigurable)?.configure(&viewModel)
      }
    #else
      (view as? SpotConfigurable)?.configure(&viewModel)
    #endif

    if let itemView = view as? SpotConfigurable, usesViewSize {
      if viewModel.size.height == 0 {
        viewModel.size.height = itemView.preferredViewSize.height
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = itemView.preferredViewSize.width
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = view.bounds.width
      }
    }

    if index < component.items.count && index > -1 {
      component.items[index] = viewModel
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
    guard let item = item(at: index), type(of: self).views.storage[item.kind] != nil
      else {
        return type(of: self).views.defaultIdentifier
    }

    return item.kind
  }


  /// Register and prepare all items in the Spotable object.
  func registerAndPrepare() {
    register()
    prepareItems()
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
}
