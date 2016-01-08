import Cocoa
import Sugar

public protocol Listable: Spotable {
  var tableView: NSTableView { get }
}

public extension Spotable where Self : Listable {}
