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
  func append(item: Item, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /**
   Append a collection of view models to a Spotable object

   - parameter items:       A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func append(items: [Item], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /**
   Prepend a collection of view models to a Spotable object

   - parameter items:      A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func prepend(items: [Item], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }

  /**
   Insert view model to a Spotable object

   - parameter item:       A Item struct
   - parameter index:      The index where the view model should be inserted
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func insert(item: Item, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }

  /**
   Update view model to a Spotable object

   - parameter item:       A Item struct
   - parameter index:      The index of the view model that should be updated
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func update(item: Item, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }

  /**
   Delete view model from a Spotable object

   - parameter item:       A Item struct
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(item: Item, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }

  /**
   Delete a collection of view models from a Spotable object

   - parameter items:       A collection of Item structs
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(items: [Item], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }

  /**
   Delete a collection of view models from a Spotable object

   - parameter index:      The index of the view model that should be deleted
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }

  /**
   Delete view model indexes with animation from a Spotable object

   - parameter indexes:    A collection of view model indexes
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }

  /**
   Reload view model indexes with animation in a Spotable object

   - parameter indexes:    A collection of view model indexes
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }

  /**
   Reload view models with change set

   - parameter changes:    A ItemChanges struct that contains instructions for the adapter to perform mutations
   - parameter animation:  A SpotAnimation that is used when performing the mutation
   - parameter updateDataSource:  A closure that updates the data source, it is performed prior to calling UI updating methods
   - parameter completion: A completion block that is run when the mutation is completed
   */
  func reloadIfNeeded(changes: ItemChanges, withAnimation animation: SpotsAnimation = .Automatic, updateDataSource: () -> Void, completion: Completion) {
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
  public var dictionary: [String : AnyObject] {
    get {
      return component.dictionary
    }
  }

  /**
   Prepare items in component
   */
  func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
    }
  }

  /**
   - parameter index: The index of the item to lookup
   - returns: A Item at found at the index
   */
  public func item(index: Int) -> Item? {
    guard index < component.items.count && index > -1 else { return nil }
    return component.items[index]
  }

  /**
   - parameter indexPath: The indexPath of the item to lookup
   - returns: A Item at found at the index
   */
  public func item(indexPath: NSIndexPath) -> Item? {
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

    return component.items.reduce(0, combine: { $0 + $1.size.height })
  }

  public func updateHeight(completion: Completion = nil) {
    Dispatch.inQueue(queue: .Interactive) { [weak self] in
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
    updatedItems.enumerate().forEach {
      updatedItems[$0.index].index = $0.index
    }

    items = updatedItems
  }

  /**
   Reloads a spot only if it changes

   - parameter items:      A collection of Items
   - parameter animation:  The animation that should be used (only works for Listable objects)
   - parameter completion: A completion closure that is performed when all mutations are performed
   */
  public func reloadIfNeeded(items: [Item], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard !(self.items == items) else {
      cache()
      return
    }

    var indexes: [Int]? = nil
    let oldItems = self.items
    self.items = items

    if items.count == oldItems.count {
      for (index, item) in items.enumerate() {
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
  public func reloadIfNeeded(json: [String : AnyObject], withAnimation animation: SpotsAnimation = .Automatic) {
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
  public func scrollTo(@noescape includeElement: (Item) -> Bool) -> CGFloat {
    return 0.0
  }

  /**
   Prepares a view model item before being used by the UI component

   - parameter index: The index of the view model
   - parameter usesViewSize: A boolean value to determine if the view uses the views height
   */
  public func configureItem(index: Int, usesViewSize: Bool = false) {
    guard let item = item(index) else { return }

    var viewModel = item
    viewModel.index = index

    let kind = item.kind.isEmpty || Self.views.storage[item.kind] == nil
      ? Self.views.defaultIdentifier
      : viewModel.kind

    guard let (_, resolvedView) = Self.views.make(kind),
      view = resolvedView else { return }

    // Set initial size for view
    view.frame.size = render().frame.size

    if let view = view as? UITableViewCell {
      view.contentView.frame = view.bounds
    }

    if let view = view as? UICollectionViewCell {
      view.contentView.frame = view.bounds
    }

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
        (view as? SpotConfigurable)?.configure(&viewModel)
      }
    #else
      (view as? SpotConfigurable)?.configure(&viewModel)
    #endif

    if usesViewSize {
      if viewModel.size.height == 0 {
        viewModel.size.height = (view as? SpotConfigurable)?.preferredViewSize.height ?? 0.0
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = (view as? SpotConfigurable)?.preferredViewSize.width ?? 0.0
      }
    }

    if index < component.items.count && index > -1 {
      component.items[index] = viewModel
    }
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return render().frame.size
  }

  func identifier(indexPath: NSIndexPath) -> String {
    #if os(OSX)
      return identifier(indexPath.item)
    #else
      return identifier(indexPath.row)
    #endif
  }

  public func identifier(index: Int) -> String {
    guard let item = item(index)
      where self.dynamicType.views.storage[item.kind] != nil
      else {
        return self.dynamicType.views.defaultIdentifier
    }

    return item.kind
  }

  func registerAndPrepare() {
    register()
    prepareItems()
  }

  func registerDefault(view view: View.Type) {
    if self.dynamicType.views.storage[self.dynamicType.views.defaultIdentifier] == nil {
      self.dynamicType.views.defaultItem = Registry.Item.classType(view)
    }
  }

  func registerComposite(view view: View.Type) {
    if self.dynamicType.views.composite == nil {
      self.dynamicType.views.composite = Registry.Item.classType(view)
    }
  }

  public static func register(nib nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  public static func register(view view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  public static func register(defaultView view: View.Type) {
    self.views.defaultItem = Registry.Item.classType(view)
  }
}
