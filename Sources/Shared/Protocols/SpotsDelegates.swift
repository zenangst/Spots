import Brick

#if os(iOS)
  import UIKit
#endif

public protocol SpotsCompositeDelegate: class {
  var compositeSpots: [Int : [Int : [Spotable]]] { get set }
}

extension SpotsCompositeDelegate {

  func resolve(spotIndex spotIndex: Int, itemIndex: Int) -> [Spotable]? {
    guard let compositeContainer = compositeSpots[spotIndex],
      result = compositeContainer[itemIndex] else {
        return nil
    }

    return result
  }
}

/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /**
   A delegate method that is triggered when spots is changed

   - parameter spots: New collection of Spotable objects
   */
  func spotsDidChange(spots: [Spotable])

  /**
   A delegate method that is triggered when ever a cell is tapped by the user

   - parameter spot: An object that conforms to the spotable protocol
   - parameter item: The view model that was tapped
   */
  func spotDidSelectItem(spot: Spotable, item: Item)
}

public extension SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: Item) {}
  func spotsDidChange(spots: [Spotable]) {}
}

/// A refresh delegate for handling reloading of a Spot
public protocol SpotsRefreshDelegate: class {

  /**
   A delegate method for when your spot controller was refreshed using pull to refresh

   - parameter refreshControl: A UIRefreshControl
   - parameter completion: A completion closure that should be triggered when the update is completed
   */
#if os(iOS)
  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion)
#endif
}

/// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
public protocol SpotsScrollDelegate: class {

  /**
   A delegate method that is triggered when the scroll view reaches the top
   */
  func spotDidReachBeginning(completion: Completion)

  /**
   A delegate method that is triggered when the scroll view reaches the end
   */
  func spotDidReachEnd(completion: Completion)
}

/// A dummy scroll delegate extension to make spotDidReachBeginning optional
public extension SpotsScrollDelegate {

  /**
   A default implementation for spotDidReachBeginning, it renders the method optional

   - parameter completion: A completion closure
   */
  func spotDidReachBeginning(completion: Completion) {
    completion?()
  }
}

public protocol SpotsCarouselScrollDelegate: class {

  func spotDidScroll(spot: Spotable)

  /**
   - parameter spot: Object that comforms to the Spotable protocol
   - parameter item: The last view model in the component
   */
  func spotDidEndScrolling(spot: Spotable, item: Item)
}
