#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A CoreComponent extension for Gridable objects
public extension CoreComponent where Self : Gridable {

  #if os(OSX)
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  var view: CollectionView {
    return collectionView
  }
  #else
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  var view: ScrollView {
    return collectionView
  }
  #endif

  /// Setup CoreComponent component with base size
  ///
  /// - parameter size: The size of the superview
  public func setup(_ size: CGSize) {
    collectionView.frame.size.width = size.width
    #if !os(OSX)
      GridComponent.configure?(collectionView, layout)

      if let resolve = type(of: self).headers.make(model.header),
        let view = resolve.view as? Componentable,
        !model.header.isEmpty {

        layout.headerReferenceSize.width = collectionView.frame.size.width
        layout.headerReferenceSize.height = view.frame.size.height

        if layout.headerReferenceSize.width == 0.0 {
          layout.headerReferenceSize.width = size.width
        }

        if layout.headerReferenceSize.height == 0.0 {
          layout.headerReferenceSize.height = view.preferredHeaderHeight
        }
      }
      collectionView.frame.size.height = layout.contentSize.height
    #endif
    layout.prepare()

    model.size = collectionView.frame.size
  }

  /// Layout with size
  ///
  /// - parameter size: A CGSize to set the width and height of the collection view
  public func layout(_ size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }

  public func configure(with layout: Layout) {
    layout.configure(spot: self)
  }
}
