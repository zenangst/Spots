import UIKit

extension CarouselSpot {

   /// A computed CGFloat of the total height of all items inside of a component
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    return collectionView.frame.height - layout.sectionInset.top - layout.sectionInset.bottom - layout.headerReferenceSize.height
  }

  /**
   Update and return the size for the item at index path

   - parameter indexPath: An NSIndexPath

   - returns: CGSize of the item at index path
   */
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    guard indexPath.item < component.items.count else { return CGSize.zero }
    var width = collectionView.frame.width

    if component.span > 0 {
      if dynamicSpan && Double(component.items.count) < component.span {
        width = collectionView.frame.width / CGFloat(component.items.count)
        width -= layout.sectionInset.left / CGFloat(component.items.count)
        width -= layout.minimumInteritemSpacing
      } else {
        width = collectionView.frame.width / CGFloat(component.span)
        width -= layout.sectionInset.left / CGFloat(component.span)
        width -= layout.minimumInteritemSpacing
      }

      component.items[indexPath.item].size.width = width
    }

    if component.items[indexPath.item].size.height == 0.0 {
      component.items[indexPath.item].size.height = collectionView.frame.height - layout.sectionInset.top - layout.sectionInset.bottom - layout.headerReferenceSize.height
    }

    return CGSize(
      width: ceil(component.items[indexPath.item].size.width),
      height: ceil(component.items[indexPath.item].size.height))
  }
}
