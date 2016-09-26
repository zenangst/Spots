import Foundation

public class ListAdapter: NSObject, SpotAdapter {
  // An unowned Listable object
  unowned var spot: Listable

  /**
   Initialization a new instance of a ListAdapter using a Listable object

   - parameter spot: A Listable object
   */
  init(spot: ListSpot) {
    self.spot = spot
  }
}
