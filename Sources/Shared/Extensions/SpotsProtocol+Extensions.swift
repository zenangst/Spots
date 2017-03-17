#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Cache

/// Compare method for generic types that conform to Comparable
///
/// - parameter lhs: Generic object on left hand side
/// - parameter rhs: Generic object on right hand side
///
/// - returns: True if lhs is lesser than rhs.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

/// Compare method for generic types that conform to Comparable
///
/// - parameter lhs: Generic object on left hand side
/// - parameter rhs: Generic object on right hand side
///
/// - returns: True if lhs is greater than rhs.
fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// MARK: - SpotsProtocol extension
public extension SpotsProtocol {

  /// A convenience property for getting a dictionary representation of the controller wihtout item reduction.
  public var dictionary: [String : Any] {
    return dictionary()
  }

  /// Produce a dictionary representation of the controller.
  ///
  /// - parameter amountOfItems: An optional Int used for getting a subset of items to cache, it set, it will save the amount of items for each Component object based on this value.
  ///
  /// - returns: A dictionary representation of the controller.
  public func dictionary(_ amountOfItems: Int? = nil) -> [String : Any] {
    var result = [[String: Any]]()

    for component in components {
      var componentJSON = component.model.dictionary(amountOfItems)
      for item in component.items where item.kind == "composite" {
        let results = component.compositeComponents
          .filter({ $0.itemIndex == item.index })

        var newItem = item
        var children = [[String: Any]]()

        for compositeSpot in results {
          children.append(compositeSpot.component.dictionary)
        }

        newItem.children = children

        var newItems = componentJSON[ComponentModel.Key.items] as? [[String : Any]]
        newItems?[item.index] = newItem.dictionary
        componentJSON[ComponentModel.Key.items] = newItems
      }

      result.append(componentJSON)
    }

    return ["components": result as AnyObject ]
  }

  /// Resolve UI component based on a predicate.
  ///
  /// - parameter includeElement: A filter predicate used to match the UI that should be resolved.
  ///
  /// - returns: An optional object with inferred type.
  public func ui<T>(_ includeElement: (Item) -> Bool) -> T? {
    for component in components {
      if let first = component.items.filter(includeElement).first {
        return component.ui(at: first.index)
      }

      let cSpots = component.compositeComponents.map { $0.component }
      for compositeSpot in cSpots {
        if let first = compositeSpot.items.filter(includeElement).first {
          return compositeSpot.ui(at: first.index)
        }
      }
    }

    return nil
  }

  /// Filter Component objects inside of controller
  ///
  /// - parameter includeElement: A filter predicate to find a component
  ///
  /// - returns: A collection of Component objects that match the includeElements predicate
  public func filter(components includeElement: (Component) -> Bool) -> [Component] {
    var result = components.filter(includeElement)

    let cSpots = components.flatMap({ $0.compositeComponents.map { $0.component } })
    let compositeResults: [Component] = cSpots.filter(includeElement)

    result.append(contentsOf: compositeResults)

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
      let items = component.items.filter(includeElement)
      if !items.isEmpty {
        result.append((component: component, items: items))
      }

      let childSpots = component.compositeComponents.map { $0.component }
      for component in childSpots {
        let items = component.items.filter(includeElement)
        if !items.isEmpty {
          result.append((component: component, items: items))
        }
      }
    }

    return result
  }

#if os(iOS)
  /// Scroll to the index of a Component object, only available on iOS.
  ///
  /// - parameter index:          The index of the component that you want to scroll
  /// - parameter includeElement: A filter predicate to find a view model
  public func scrollTo(componentIndex index: Int = 0, includeElement: (Item) -> Bool) {
    guard let itemY = component(at: index)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += components[0..<index].reduce(0, { $0 + $1.computedHeight })
    }
    if component(at: index)?.computedHeight > scrollView.frame.height - scrollView.contentInset.bottom - initialHeight {
      let y = itemY - scrollView.frame.size.height + scrollView.contentInset.bottom + initialHeight
      scrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /// Scroll to the bottom of the controller
  ///
  /// - parameter animated: A boolean in indicate if the scrolling should be done with animation.
  public func scrollToBottom(_ animated: Bool) {
    let y = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom
    scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
#endif

  /// Caches the current state of the controller
  ///
  /// - parameter items: An optional integer that is used to reduce the amount of items that should be cached per Component object when saving the view state to disk
  public func cache(_ items: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache: stateCache)
    #endif

    stateCache?.save(dictionary(items))
  }

  /// Clear the Spots cache
  @available(*, deprecated, message: "Use StateCache.removeAll() instead.")
  public static func clearCache() {
    let path = StateCache(key: "").path

    do {
      try FileManager.default.removeItem(atPath: path)
    } catch {
      NSLog("Could not remove cache at path: \(path)")
    }
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
