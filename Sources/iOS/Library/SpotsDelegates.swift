import UIKit
import Brick

public protocol SpotsDelegate: class {

  /**
   A delegate method that is triggered when ever a cell is tapped by the user

   - Parameter spot: An object that conforms to the spotable protocol
   - Parameter item: The view model that was tapped
   */
  func spotDidSelectItem(spot: Spotable, item: ViewModel)
}

public protocol SpotsRefreshDelegate: class {

  /**
   A delegate method for when your spot controller was refreshed using pull to refresh

   - Parameter refreshControl: A UIRefreshControl
   - Parameter completion: A completion closure that should be triggered when the update is completed
   */
  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
}

public protocol SpotsScrollDelegate: class {

  /**
   A delegate method that is triggered when the scroll view reaches the top
   */
  func spotDidReachBeginning(completion: (() -> Void)?)

  /**
   A delegate method that is triggered when the scroll view reaches the end
   */
  func spotDidReachEnd(completion: (() -> Void)?)
}

public extension SpotsScrollDelegate {

  /**
   A default implementation for spotDidReachBeginning, it renders the method optional
   */
  func spotDidReachBeginning(completion: (() -> Void)?) {
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
