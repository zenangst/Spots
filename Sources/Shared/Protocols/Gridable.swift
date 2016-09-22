#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Gridable: Spotable {

  /// The layout object used to initialize the collection spot controller.
  var layout: CollectionLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: CollectionView { get }

  #if !os(OSX)
  static var headers: Registry { get set }
  #endif

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize

  #if os(OSX)
  static var grids: GridRegistry { get set }
  static var defaultGrid: NSCollectionViewItem.Type { get }
  #endif
}
