#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick
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
    get { return dictionary() }
  }

  /// Produce a dictionary representation of the controller.
  ///
  /// - parameter amountOfItems: An optional Int used for getting a subset of items to cache, it set, it will save the amount of items for each Spotable object based on this value.
  ///
  /// - returns: A dictionary representation of the controller.
  public func dictionary(_ amountOfItems: Int? = nil) -> [String : Any] {
    var result = [[String : Any]]()

    for spot in spots {
      var spotJSON = spot.component.dictionary(amountOfItems)
      for item in spot.items where item.kind == "composite" {
        if let compositeSpots = compositeSpots[spot.index]?[item.index] {
          var newItem = item
          var children = [[String : Any]]()
          for itemSpot in compositeSpots {
            children.append(itemSpot.dictionary)
          }
          newItem.children = children
          var newItems = spotJSON[Component.Key.Items] as? [[String : Any]]

          newItems?[item.index] = newItem.dictionary
          spotJSON[Component.Key.Items] = newItems
        }
      }

      result.append(spotJSON)
    }

    return ["components" : result as AnyObject ]
  }

  /// Resolve UI component based on a predicate.
  ///
  /// - parameter includeElement: A filter predicate used to match the UI that should be resolved.
  ///
  /// - returns: An optional object with inferred type.
  public func ui<T>(_ includeElement: (Item) -> Bool) -> T? {
    for spot in spots {
      if let first = spot.items.filter(includeElement).first {
        return spot.ui(atIndex: first.index)
      }
    }

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerated() {
        for spot in spots.1 {
          if let first = spot.items.filter(includeElement).first {
            return spot.ui(atIndex: first.index)
          }
        }
      }
    }

    return nil
  }

  /// Filter Spotable objects inside of controller
  ///
  /// - parameter includeElement: A filter predicate to find a spot
  ///
  /// - returns: A collection of Spotable objects that match the includeElements predicate
  public func filter(spots includeElement: (Spotable) -> Bool) -> [Spotable] {
    var result = spots.filter(includeElement)

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerated() {
        let compositeResults = spots.1.filter(includeElement)
        if !compositeResults.isEmpty { result.append(contentsOf: compositeResults) }
      }
    }

    return result
  }

  /// Filter items based on predicate.
  ///
  /// - parameter includeElement: The predicate that the item has to match.
  ///
  /// - returns: A collection of tuples containing spotable objects with the matching items that were found.
  public func filter(items includeElement: (Item) -> Bool) -> [(spot: Spotable, items: [Item])] {
    var result = [(spot: Spotable, items: [Item])]()
    for spot in spots {
      let items = spot.items.filter(includeElement)
      if !items.isEmpty {
        result.append((spot: spot, items: items))
      }
    }

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerated() {
        for spot in spots.1 {
          let items = spot.items.filter(includeElement)
          if !items.isEmpty {
            result.append((spot: spot, items: items))
          }
        }
      }
    }

    return result
  }

#if os(iOS)
  /// Scroll to the index of a Spotable object, only available on iOS.
  ///
  /// - parameter index:          The index of the spot that you want to scroll
  /// - parameter includeElement: A filter predicate to find a view model
  public func scrollTo(spotIndex index: Int = 0, includeElement: (Item) -> Bool) {
    guard let itemY = spot(at: index, Spotable.self)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += spots[0..<index].reduce(0, { $0 + $1.computedHeight })
    }
    if spot(at: index, Spotable.self)?.computedHeight > scrollView.frame.height - scrollView.contentInset.bottom - initialHeight {
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
  /// - parameter items: An optional integer that is used to reduce the amount of items that should be cached per Spotable object when saving the view state to disk
  public func cache(_ items: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache: stateCache)
    #endif

    stateCache?.save(dictionary(items))
  }

  /// Clear the Spots cache
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                    FileManager.SearchPathDomainMask.userDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(StateCache.cacheName)"
    do {
      try FileManager.default.removeItem(atPath: path)
    } catch {
      NSLog("Could not remove cache at path: \(path)")
    }
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of the component belonging to the Spotable object at that index.
  ///
  /// - returns: A Component object at index path.
  fileprivate func component(at indexPath: IndexPath) -> Component {
    return spot(at: indexPath).component
  }

  /**
   - parameter indexPath: The index path of the spot you want to lookup
   - returns: A Spotable object at index path
   **/
  fileprivate func spot(at indexPath: IndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
