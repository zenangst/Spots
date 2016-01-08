import Cocoa
import Sugar

public protocol Gridable: Spotable {
  var layout: NSCollectionViewFlowLayout { get }
  var collectionView: NSCollectionView { get }
}

public extension Spotable where Self : Gridable {}
