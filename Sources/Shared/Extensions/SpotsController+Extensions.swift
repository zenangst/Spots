#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Cache

// MARK: - SpotsProtocol extension
public extension SpotsController {
  /// Resolve UI component based on a predicate.
  ///
  /// - parameter includeElement: A filter predicate used to match the UI that should be resolved.
  ///
  /// - returns: An optional object with inferred type.
  public func ui<T>(_ includeElement: (Item) -> Bool) -> T? {
    for component in components {
      if let first = component.model.items.filter(includeElement).first {
        return component.ui(at: first.index)
      }
    }

    return nil
  }

  /// Resolve item model on item
  ///
  /// - parameter includeElement: A filter predicate used to match the item model that should be resolved.
  ///
  /// - returns: An optional item model with inferred type.
  public func itemModel<T>(_ includeElement: (Item) -> Bool) -> T? {
    for component in components {
      if let match = component.model.items.filter(includeElement).first {
        return match.model as? T
      }
    }

    return nil
  }

  /// Filter components. inside of controller
  ///
  /// - parameter includeElement: A filter predicate to find a component
  ///
  /// - returns: A collection of components. that match the includeElements predicate
  public func filter(components includeElement: (Component) -> Bool) -> [Component] {
    let result = components.filter(includeElement)
    return result
  }

  /// Filter items based on predicate.
  ///
  /// - parameter includeElement: The predicate that the item has to match.
  ///
  /// - returns: A collection of tuples containing components with the matching items that were found.
  public func filter(items includeElement: (Item) -> Bool) -> [(component: Component, items: [Item])] {
    var result = [(component: Component, items: [Item])]()
    for component in components {
      let items = component.model.items.filter(includeElement)
      if !items.isEmpty {
        result.append((component: component, items: items))
      }
    }

    return result
  }

  /// Caches the current state of the controller
  ///
  /// - parameter amountOfItems: An optional integer that is used to reduce the amount of items that should be cached per Component object when saving the view state to disk
  public func cache(_ amountOfItems: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache: stateCache)
    #endif

    let componentModels = components.map({ component -> ComponentModel in
      var model = component.model
      if let amountOfItems = amountOfItems {
        model.amountOfItemsToCache = amountOfItems
      }
      return model
    })

    stateCache?.save(componentModels)
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of the component belonging to the Component object at that index.
  ///
  /// - returns: A ComponentModel object at index path.
  func component(at index: Int) -> Component? {
    guard index >= 0 && index < components.count else {
      return nil
    }
    return components[index]
  }
}
