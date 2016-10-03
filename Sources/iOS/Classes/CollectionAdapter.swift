import UIKit

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
open class CollectionAdapter: NSObject, SpotAdapter {
  // An unowned Gridable object
  unowned var spot: Gridable

  /**
   Initialization a new instance of a CollectionAdapter using a Gridable object

   - parameter spot: A Gridable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }
}
