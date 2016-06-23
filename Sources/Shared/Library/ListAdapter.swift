import Foundation
import Sugar
import Brick

public class ListAdapter: NSObject, SpotAdapter {
  // An unowned Listable object
  #if os(OSX)
  var spot: Listable
  #else
  unowned var spot: Listable
  #endif

  /**
   Initialization a new instance of a ListAdapter using a Listable object

   - Parameter gridable: A Listable object
   */
  init(spot: ListSpot) {
    self.spot = spot
  }
}
