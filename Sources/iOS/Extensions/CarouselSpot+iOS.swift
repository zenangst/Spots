import UIKit

/// An extension on CarouselSpot to object specific behavior.
extension CarouselSpot {

  /// Update and return the size for the item at index path.
  ///
  /// - parameter indexPath: indexPath: An NSIndexPath.
  ///
  /// - returns: CGSize of the item at index path.
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    guard indexPath.item < component.items.count else { return CGSize.zero }
    var width = collectionView.frame.width

    let gridableLayout = layout

    if let layout = component.layout {
      if layout.span > 0.0 {
        if dynamicSpan && Double(component.items.count) < layout.span {
          width = collectionView.frame.width / CGFloat(component.items.count)
          width -= gridableLayout.sectionInset.left / CGFloat(component.items.count)
          width -= gridableLayout.minimumInteritemSpacing
        } else {
          width = collectionView.frame.width / CGFloat(layout.span)
          width -= gridableLayout.sectionInset.left / CGFloat(layout.span)
          width -= gridableLayout.minimumInteritemSpacing
        }

        component.items[indexPath.item].size.width = width
      }
    }

    if component.items[indexPath.item].size.height == 0.0 {
      component.items[indexPath.item].size.height = collectionView.frame.height - layout.sectionInset.top - layout.sectionInset.bottom - layout.headerReferenceSize.height
    }

    return CGSize(
      width: ceil(component.items[indexPath.item].size.width),
      height: ceil(component.items[indexPath.item].size.height))
  }
}
