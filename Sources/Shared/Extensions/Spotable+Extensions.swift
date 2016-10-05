#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick

public extension Spotable {

  /// A computed value for the current index
  public var index: Int {
    return component.index
  }

  /**
   Resolve UI component at index (UITableViewCell or UICollectionViewItem)

   - parameter index: The index of the view model

   - returns: An optional UI component, most likely a UITableViewCell or UICollectionViewCell
   */
  public func ui<T>(atIndex index: Int) -> T? {
    return adapter?.ui(atIndex: index)
  }

  /**
   Append view model to a Spotable object

   - parameter item:       A Item struct
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func append(_ item: Item, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /**
   Append a collection of view models to a Spotable object

   - parameter items:       A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func append(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /**
   Prepend a collection of view models to a Spotable object

   - parameter items:      A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func prepend(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }

  /**
   Insert view model to a Spotable object

   - parameter item:       A Item struct
   - parameter index:      The index where the view model should be inserted
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }

  /**
   Update view model to a Spotable object

   - parameter item:       A Item struct
   - parameter index:      The index of the view model that should be updated
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }

  /**
   Delete view model from a Spotable object

   - parameter item:       A Item struct
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(_ item: Item, withAnimation animation: SpotsAnimation = .automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }

  /**
   Delete a collection of view models from a Spotable object

   - parameter items:       A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(_ items: [Item], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }

  /**
   Delete a collection of view models from a Spotable object

   - parameter index:      The index of the view model that should be deleted
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(_ index: Int, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }

  /**
   Delete view model indexes with animation from a Spotable object

   - parameter indexes:    A collection of view model indexes
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }

  /**
   Reload view model indexes with animation in a Spotable object

   - parameter indexes:    A collection of view model indexes
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func reload(_ indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }

  /**
   Reload view models with change set

   - parameter changes:    A ItemChanges struct that contains instructions for the adapter to perform mutations
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter updateDataSource:  A closure that updates the data source, it is performed prior to calling UI updating methods
   - parameter completion: A completion block that is run when the mutation is completed
   */
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

  /**
   Prepare items in component
   */
  func prepareItems() {
    component.items.enumerated().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
    }
  }

  /**
   - parameter index: The index of the item to lookup
   - returns: A Item at found at the index
   */
  public func item(_ index: Int) -> Item? {
    guard index < component.items.count && index > -1 else { return nil }
    return component.items[index]
  }

  /**
   - parameter indexPath: The indexPath of the item to lookup
   - returns: A Item at found at the index
   */
  public func item(_ indexPath: IndexPath) -> Item? {
    #if os(OSX)
      return item(indexPath.item)
    #else
      return item(indexPath.row)
    #endif
  }

  /**
   - returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    return component.items.reduce(0, { $0 + $1.size.height })
  }

  public func updateHeight(_ completion: Completion = nil) {
    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else { Dispatch.mainQueue { completion?(); }; return }
      let spotHeight = weakSelf.spotHeight()
      Dispatch.mainQueue { [weak self] in
        self?.render().frame.size.height = spotHeight
        completion?()
      }
    }
  }

  /**
   Refreshes the indexes of all items within the component
   */
  public func refreshIndexes() {
    var updatedItems  = items
    updatedItems.enumerated().forEach {
      updatedItems[$0.offset].index = $0.offset
    }

    items = updatedItems
  }

  /**
   Reloads a spot only if it changes

   - parameter items:      A collection of Items
   - parameter animation:  The animation that should be used (only works for Listable objects)
   - parameter completion: A completion closure that is performed when all mutations are performed
   */
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

  /**
   Reload Spotable object with JSON if contents changed

   - parameter json:      A JSON dictionary
   - parameter animation:  A SpotAnimation that is used when performing the mutation (only works for Listable objects)
   */
  public func reloadIfNeeded(_ json: [String : Any], withAnimation animation: SpotsAnimation = .automatic) {
    let newComponent = Component(json)

    guard component != newComponent else { cache(); return }

    component = newComponent
    reload(nil, withAnimation: animation) { [weak self] in
      self?.cache()
    }
  }

  /**
   Caches the current state of the spot
   */
  public func cache() {
    stateCache?.save(dictionary)
  }

  /**
   - parameter includeElement: A filter predicate to find a view model
   - returns: Always returns 0.0
   */
  public func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat {
    return 0.0
  }

  /**
   Prepares a view model item before being used by the UI component

   - parameter index: The index of the view model
   - parameter usesViewSize: A boolean value to determine if the view uses the views height
   */
  public func configureItem(_ index: Int, usesViewSize: Bool = false) {
    guard let item = item(index) else { return }

    var viewModel = item
    viewModel.index = index

    let kind = item.kind.isEmpty || Self.views.storage[item.kind] == nil
      ? Self.views.defaultIdentifier
      : viewModel.kind

    guard let (_, resolvedView) = Self.views.make(kind),
      let view = resolvedView else { return }

    #if !os(OSX)
      if let composite = view as? SpotComposable {
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
        viewModel.size.height = itemView.preferredViewSize.height ?? 0.0
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = itemView.preferredViewSize.width ?? 0.0
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = view.bounds.width
      }
    }

    if index < component.items.count && index > -1 {
      component.items[index] = viewModel
    }
  }

  public func sizeForItemAt(_ indexPath: IndexPath) -> CGSize {
    return render().frame.size
  }

  func identifier(_ indexPath: IndexPath) -> String {
    #if os(OSX)
      return identifier(indexPath.item)
    #else
      return identifier((indexPath as NSIndexPath).row)
    #endif
  }

  public func identifier(_ index: Int) -> String {
    guard let item = item(index), type(of: self).views.storage[item.kind] != nil
      else {
        return type(of: self).views.defaultIdentifier
    }

    return item.kind
  }

  func registerAndPrepare() {
    register()
    prepareItems()
  }

  func registerDefault(_ view: View.Type) {
    if type(of: self).views.storage[type(of: self).views.defaultIdentifier] == nil {
      type(of: self).views.defaultItem = Registry.Item.classType(view)
    }
  }

  func registerComposite(_ view: View.Type) {
    if type(of: self).views.composite == nil {
      type(of: self).views.composite = Registry.Item.classType(view)
    }
  }

  public static func register(_ nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  public static func register(_ view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  public static func register(defaultView view: View.Type) {
    self.views.defaultItem = Registry.Item.classType(view)
  }
}
