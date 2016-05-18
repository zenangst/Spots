#if os(iOS)
import UIKit
#endif

import Brick

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

public protocol SpotsCarouselScrollDelegate: class {

  /**
   - Parameter spot: Object that comforms to the Spotable protocol
   - Parameter item: The last view model in the component
   */
  func spotDidEndScrolling(spot: Spotable, item: ViewModel)
}