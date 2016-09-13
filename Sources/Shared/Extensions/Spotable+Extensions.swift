#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick
import Sugar

public extension Spotable {

  public var index: Int {
    return component.index
  }

  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }
  /// Delete a collection of view models from a Spotable object
  func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }

  /// Reload view models with change set
  func reloadIfNeeded(changes: ViewModelChanges, updateDataSource: () -> Void, completion: Completion) {
    adapter?.reloadIfNeeded(changes, updateDataSource: updateDataSource, completion: completion)
  }

  /// A collection of view models
  var items: [ViewModel] {
    set(items) { component.items = items }
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
   - Parameter index: The index of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(index: Int) -> ViewModel? {
    guard index < component.items.count && index > -1 else { return nil }
    return component.items[index]
  }

  /**
   - Parameter indexPath: The indexPath of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(indexPath: NSIndexPath) -> ViewModel? {
    #if os(OSX)
      return item(indexPath.item)
    #else
      return item(indexPath.row)
    #endif
  }

  /**
   - Returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    return component.items.reduce(0, combine: { $0 + $1.size.height })
  }

  public func updateHeight(completion: Completion = nil) {
    dispatch(queue: .Interactive) { [weak self] in
      guard let weakSelf = self else { dispatch { completion?(); }; return }
      let spotHeight = weakSelf.spotHeight()
      dispatch { [weak self] in
        self?.render().frame.size.height = spotHeight
        completion?()
      }
    }
  }

  /**
   Refreshes the indexes of all items within the component
   */
  public func refreshIndexes() {
    items.enumerate().forEach {
      items[$0.index].index = $0.index
    }
  }

  /**
   Reloads a spot only if it changes

   - Parameter items:     A collection of ViewModels
   - Parameter animation: The animation that should be used (only works for Listable objects)
   */
  public func reloadIfNeeded(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
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

   - Parameter json:      A JSON dictionary
   - Parameter animation: The animation that should be used (only works for Listable objects)
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
   - Parameter includeElement: A filter predicate to find a view model
   - Returns: Always returns 0.0
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    return 0.0
  }

  /**
   Prepares a view model item before being used by the UI component

   - Parameter index: The index of the view model
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

    #if !os(OSX)
      if let composite = view as? SpotComposable {
        let spots = composite.parse(viewModel)
        for spot in spots {
          spot.registerAndPrepare()
          spot.render().optimize()
        }

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
        viewModel.size.height = (view as? SpotConfigurable)?.size.height ?? 0.0
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = (view as? SpotConfigurable)?.size.width ?? 0.0
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

  public static func register(nib nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  public static func register(view view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  public static func register(defaultView view: View.Type) {
    self.views.storage[self.views.defaultIdentifier] = Registry.Item.classType(view)
  }
}
