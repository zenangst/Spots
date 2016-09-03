/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Listable: Spotable {

  #if !os(OSX)
  static var headers: Registry { get set }
  #endif

  var tableView: TableView { get }
}
