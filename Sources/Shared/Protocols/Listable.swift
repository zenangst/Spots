/// Listable is protocol for Spots that are based on table views-
public protocol Listable: Spotable {

  #if !os(OSX)
  /// The headers that should be used on the Listable object, only available on macOS.
  static var headers: Registry { get set }
  #endif

  /// A required table view
  var tableView: TableView { get }
}
