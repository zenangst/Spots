#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

/// A Spotable extension for Gridable objects
public extension Spotable where Self : Gridable {

  /**
   - returns: UIScrollView: Returns a UICollectionView as a UIScrollView
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
   - parameter size: A CGSize to set the size of the collection view
   */
  public func setup(size: CGSize) {
    layout.prepareLayout()
    collectionView.frame.size.width = size.width
    #if !os(OSX)
      collectionView.frame.size.height = layout.contentSize.height
      GridSpot.configure?(view: collectionView, layout: layout)
    #endif
    component.size = collectionView.frame.size
  }

  /**
   - parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }

  public func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
      if component.span > 0 {
        #if os(OSX)
          if let layout = layout as? NSCollectionViewFlowLayout {
            component.items[index].size.width = collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
          }
        #else
          component.items[index].size.width = collectionView.bounds.size.width / CGFloat(component.span)
        #endif
      }
    }
  }
}
