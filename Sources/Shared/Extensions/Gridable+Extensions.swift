#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

/// A Spotable extension for Gridable objects
public extension Spotable where Self : Gridable {

  #if os(OSX)
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  public func render() -> CollectionView {
    return collectionView
  }
  #else
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  public func render() -> ScrollView {
    return collectionView
  }
  #endif

  /// Setup Spotable component with base size
  ///
  /// - parameter size: The size of the superview
  public func setup(_ size: CGSize) {
    layout.prepare()
    collectionView.frame.size.width = size.width
    #if !os(OSX)
      collectionView.frame.size.height = layout.contentSize.height
      GridSpot.configure?(collectionView, layout)
    #endif
    component.size = collectionView.frame.size
  }

  /// Layout with size
  ///
  /// - parameter size: A CGSize to set the width and height of the collection view
  public func layout(_ size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }

  /// Prepare items in component
  public func prepareItems() {
    component.items.enumerated().forEach { (index: Int, _) in
      configureItem(at: index, usesViewSize: true)
      if component.span > 0 {
        #if os(OSX)
          if let layout = layout as? NSCollectionViewFlowLayout {
            component.items[index].size.width = collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
          }
        #else
          var spotWidth = collectionView.frame.size.width

          if spotWidth == 0.0 {
            spotWidth = UIScreen.main.bounds.width
          }

          let newWidth = spotWidth / CGFloat(component.span)
          component.items[index].size.width = newWidth
        #endif
      }
    }
  }
}
