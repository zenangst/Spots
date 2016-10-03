#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick
import Cache
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public extension SpotsProtocol {

  public var dictionary: [String : Any] {
    get { return dictionary() }
  }

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

  /**
   Filter Spotable objects inside of controller

   - parameter includeElement: A filter predicate to find a spot

   - returns:  A collection of Spotable objects that match the includeElements predicate
   */
  public func filter(_ includeElement: (Spotable) -> Bool) -> [Spotable] {
    var result = spots.filter(includeElement)

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerated() {
        let compositeResults = spots.1.filter(includeElement)
        if !compositeResults.isEmpty { result.append(contentsOf: compositeResults) }
      }
    }

    return result
  }

  /**
   Filter view models in all Spotable objects inside of the controller

   - parameter includeElement: A filter predicate to find view models
   */
  public func filterItems(_ includeElement: (Item) -> Bool) -> [(spot: Spotable, items: [Item])] {
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
  /**
   - parameter index: The index of the spot that you want to scroll
   - parameter includeElement: A filter predicate to find a view model
   */
  public func scrollTo(spotIndex index: Int = 0, includeElement: (Item) -> Bool) {
    guard let itemY = spot(index, Spotable.self)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += spots[0..<index].reduce(0, { $0 + $1.spotHeight() })
    }
    if spot(index, Spotable.self)?.spotHeight() > spotsScrollView.frame.height - spotsScrollView.contentInset.bottom - initialHeight {
      let y = itemY - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom + initialHeight
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /**
   - parameter animated: A boolean value to determine if you want to perform the scrolling with or without animation
   */
  public func scrollToBottom(_ animated: Bool) {
    let y = spotsScrollView.contentSize.height - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom
    spotsScrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
#endif

  /**
   Caches the current state of the spot controller

   - parameter items: An optional integer that is used to reduce the amount of items that should be cached per Spotable object when saving the view state to disk
   */
  public func cache(items: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache)
    #endif

    stateCache?.save(dictionary(items))
  }

  /**
   Clear Spots cache
   */
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                    FileManager.SearchPathDomainMask.userDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(SpotCache.cacheName)"
    do {
      try FileManager.default.removeItem(atPath: path)
    } catch {
      NSLog("Could not remove cache at path: \(path)")
    }
  }

  /**
   - parameter indexPath: The index path of the component you want to lookup
   - returns: A Component object at index path
   **/
  fileprivate func component(_ indexPath: IndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - parameter indexPath: The index path of the spot you want to lookup
   - returns: A Spotable object at index path
   **/
  fileprivate func spot(_ indexPath: IndexPath) -> Spotable {
    return spots[(indexPath as NSIndexPath).item]
  }
}
