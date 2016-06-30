import Foundation

public class ListAdapter: NSObject, SpotAdapter {
  // An unowned Listable object
  unowned var spot: Listable

  /**
   Initialization a new instance of a ListAdapter using a Listable object

   - Parameter gridable: A Listable object
   */
  init(spot: ListSpot) {
    self.spot = spot
  }
}
