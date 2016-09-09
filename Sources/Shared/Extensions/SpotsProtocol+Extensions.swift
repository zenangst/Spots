#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Sugar
import Brick
import Cache

public extension SpotsProtocol {

  public var dictionary: [String : AnyObject] {
    get { return dictionary() }
  }

  public func dictionary(amountOfItems: Int? = nil) -> [String : AnyObject] {
    var result = [[String : AnyObject]]()

    for spot in spots {
      var spotJSON = spot.component.dictionary(amountOfItems)
      for item in spot.items where item.kind == "composite" {
        if let compositeSpots = compositeSpots[spot.index]?[item.index] {
          var newItem = item
          var children = [[String : AnyObject]]()
          for itemSpot in compositeSpots {
            children.append(itemSpot.dictionary)
          }
          newItem.children = children
          var newItems = spotJSON[Component.Key.Items] as? [[String : AnyObject]]

          newItems?[item.index] = newItem.dictionary
          spotJSON[Component.Key.Items] = newItems
        }
      }

      result.append(spotJSON)
    }

    return ["components" : result ]
  }

  /**
   - Parameter includeElement: A filter predicate to find a spot
   */
  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    var result = spots.filter(includeElement)

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerate() {
        let compositeResults = spots.1.filter(includeElement)
        if !compositeResults.isEmpty { result.appendContentsOf(compositeResults) }
      }
    }

    return result
  }

  public func filterItems(@noescape includeElement: (ViewModel) -> Bool) -> [(spot: Spotable, items: [ViewModel])] {
    var result = [(spot: Spotable, items: [ViewModel])]()
    for spot in spots {
      let items = spot.items.filter(includeElement)
      if !items.isEmpty {
        result.append((spot: spot, items: items))
      }
    }

    for (_, cSpots) in compositeSpots {
      for (_, spots) in cSpots.enumerate() {
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
   - Parameter index: The index of the spot that you want to scroll
   - Parameter includeElement: A filter predicate to find a view model
   */
  public func scrollTo(spotIndex index: Int = 0, @noescape includeElement: (ViewModel) -> Bool) {
    guard let itemY = spot(index, Spotable.self)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += spots[0..<index].reduce(0, combine: { $0 + $1.spotHeight() })
    }
    if spot(index, Spotable.self)?.spotHeight() > spotsScrollView.frame.height - spotsScrollView.contentInset.bottom - initialHeight {
      let y = itemY - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom + initialHeight
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /**
   - Parameter animated: A boolean value to determine if you want to perform the scrolling with or without animation
   */
  public func scrollToBottom(animated: Bool) {
    let y = spotsScrollView.contentSize.height - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom
    spotsScrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
#endif

  /**
   Caches the current state of the spot controller
   */
  public func cache(items items: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache)
    #endif

    stateCache?.save(dictionary(items))
  }

  /**
   Clear Spots cache
   */
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                    NSSearchPathDomainMask.UserDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(SpotCache.cacheName)"
    do {
      try NSFileManager.defaultManager().removeItemAtPath(path)
    } catch {
      NSLog("Could not remove cache at path: \(path)")
    }
  }

  /**
   - Parameter indexPath: The index path of the component you want to lookup
   - Returns: A Component object at index path
   **/
  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - Parameter indexPath: The index path of the spot you want to lookup
   - Returns: A Spotable object at index path
   **/
  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
