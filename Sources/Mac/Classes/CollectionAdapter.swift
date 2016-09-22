import Cocoa

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject, SpotAdapter {
  // An unowned Gridable object
  unowned var spot: Gridable

  /**
   Initialization a new instance of a ListAdapter using a Gridable object

   - Parameter gridable: A Listable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }
}
