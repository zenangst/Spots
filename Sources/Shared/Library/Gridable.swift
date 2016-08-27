#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Sugar
import Brick

public struct GridableMeta {
  public struct Key {
    public static let sectionInsetTop = "inset-top"
    public static let sectionInsetLeft = "inset-left"
    public static let sectionInsetRight = "inset-right"
    public static let sectionInsetBottom = "inset-bottom"
  }
}

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

/// A Spotable extension for Gridable objects
public extension Spotable where Self : Gridable {

  /**
   - Returns: UIScrollView: Returns a UICollectionView as a UIScrollView
   */
   #if os(OSX)
  public func render() -> CollectionView {
    return collectionView
  }
  #else
  public func render() -> ScrollView {
  return collectionView
  }
  #endif

  /**
   - Parameter size: A CGSize to set the size of the collection view
   */
  public func setup(size: CGSize) {
    collectionView.frame.size = size
    #if os(OSX)
      #else
      GridSpot.configure?(view: collectionView, layout: layout)
    #endif
  }

  /**
   - Parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
    guard let componentSize = component.size else { return }
    collectionView.frame.size.height = componentSize.height
  }

  public func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
      if component.span > 0 {
        #if os(OSX)
          if let layout = layout as? NSCollectionViewFlowLayout where component.span > 0 {
            component.items[index].size.width = collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
          }
        #else
          component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
        #endif
      }
    }
  }
}
