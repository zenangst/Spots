import Cocoa
import Brick

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Listable: Spotable {

  var tableView: NSTableView { get }
}
