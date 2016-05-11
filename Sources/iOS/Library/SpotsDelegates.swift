import UIKit
import Brick

/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /**
   A delegate method that is triggered when spots is changed

   - parameter spots: New collection of Spotable objects
   */
  func spotsDidChange(spots: [Spotable])

  /**
   A delegate method that is triggered when ever a cell is tapped by the user

   - Parameter spot: An object that conforms to the spotable protocol
   - Parameter item: The view model that was tapped
   */
  func spotDidSelectItem(spot: Spotable, item: ViewModel)
}

public extension SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {}
  func spotsDidChange(spots: [Spotable]) {}
}

/// A refresh delegate for handling reloading of a Spot
public protocol SpotsRefreshDelegate: class {

  /**
   A delegate method for when your spot controller was refreshed using pull to refresh

   - Parameter refreshControl: A UIRefreshControl
   - Parameter completion: A completion closure that should be triggered when the update is completed
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
   */
  func spotDidReachBeginning(completion: Completion) {
    completion?()
  }
}

public protocol SpotsCarouselScrollDelegate: class {

  /**
   - Parameter spot: Object that comforms to the Spotable protocol
   - Parameter item: The last view model in the component
   */
  func spotDidEndScrolling(spot: Spotable, item: ViewModel)
}
