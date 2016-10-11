import Foundation

/// The ListAdapter works as a proxy handler for all Listable object.
open class ListAdapter: NSObject, SpotAdapter {
  // An Listable object
  var spot: Listable

  /// Initialization a new instance of a CollectionAdapter using a Listable object.
  ///
  /// - parameter spot: A List object.
  ///
  /// - returns: An initialized list adapter.
  init(spot: Listable) {
    self.spot = spot
  }
}
