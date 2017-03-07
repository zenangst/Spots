#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// Gridable is protocol for Spots that are based on collection views.
public protocol Gridable: CoreComponent {

  /// The layout object used to initialize the collection spot controller.
  var layout: CollectionLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: CollectionView { get }

  #if !os(OSX)
  /// The headers that should be used on the Gridable object, only available on macOS.
  static var headers: Registry { get set }
  #endif

  /// Asks the data source for the size of an item in a particular location.
  ///
  /// - parameter indexPath: The index path of the
  ///
  /// - returns: Size of the object at index path as CGSize
  func sizeForItem(at indexPath: IndexPath) -> CGSize

  #if os(OSX)
  /// A registry for Gridable objects, only available on macOS.
  static var grids: GridRegistry { get set }
  /// The default grid item that should be used in the Gridable object, only available on macOS.
  static var defaultGrid: NSCollectionViewItem.Type { get }
  #endif
}
