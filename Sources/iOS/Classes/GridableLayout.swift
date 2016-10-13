import UIKit

/// A custom flow layout used in GridSpot and CarouselSpot
open class GridableLayout: UICollectionViewFlowLayout {

  /// The content size for the Gridable object
  var contentSize = CGSize.zero
  /// The y offset for the Gridable object
  open var yOffset: CGFloat?

  // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
  open override var collectionViewContentSize: CGSize {
    return contentSize
  }

  /// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
  /// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
  /// Subclasses should always call super if they override.
  open override func prepare() {
    super.prepare()

    guard let spot = collectionView?.delegate as? Gridable,
      let firstItem = spot.items.first else { return }
    contentSize.width = spot.items.reduce(0, { $0 + $1.size.width })
    contentSize.width += CGFloat(spot.items.count) * (minimumInteritemSpacing)
    contentSize.width += sectionInset.left + (sectionInset.right / 2) - 3
    contentSize.width = ceil(contentSize.width)

    if scrollDirection == .horizontal {
      contentSize.height = firstItem.size.height + headerReferenceSize.height
      contentSize.height += sectionInset.top + sectionInset.bottom

      if let spot = spot as? CarouselSpot, spot.pageIndicator {
        contentSize.height += spot.pageControl.frame.height
      }
    } else {
      contentSize.height = spot.items.reduce(0, { $0 + $1.size.height })
      if spot.component.span > 1 {
        let count = spot.items.count
        if let last = spot.items.last, count % Int(spot.component.span) != 0 {
          contentSize.height += last.size.height
        }

        contentSize.height += CGFloat(spot.items.count) * minimumLineSpacing
        contentSize.height /= CGFloat(spot.component.span)
        contentSize.height += sectionInset.top + sectionInset.bottom
      } else {
        contentSize.height = spot.items.reduce(0, { $0 + $1.size.height })
        contentSize.height += sectionInset.top + sectionInset.bottom
      }
    }
  }

  /// Invalidates the current layout and triggers a layout update.
  open override func invalidateLayout() {
    super.invalidateLayout()

    guard let collectionView = collectionView else { return }

    if let y = yOffset, collectionView.isDragging && headerReferenceSize.height > 0.0 {
      collectionView.frame.origin.y = y
    }
  }


  /// Returns the layout attributes for all of the cells and views in the specified rectangle.
  ///
  /// - parameter rect: The rectangle (specified in the collection view’s coordinate system) containing the target views.
  ///
  /// - returns: An array of layout attribute objects containing the layout information for the enclosed items and views. The default implementation of this method returns nil.
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView,
      let spot = collectionView.dataSource as? Gridable
      else { return nil }

    var attributes = [UICollectionViewLayoutAttributes]()
    var rect = CGRect(origin: CGPoint.zero, size: contentSize)

    if headerReferenceSize.height > 0.0 {
      rect.origin = CGPoint(x: -collectionView.bounds.width, y: 0)
      rect.size.height = contentSize.height
      rect.size.width = collectionView.bounds.width * 3
    }

    if let newAttributes = super.layoutAttributesForElements(in: rect) {
      var offset: CGFloat = sectionInset.left
      for attribute in newAttributes {
        guard let itemAttribute = attribute.copy() as? UICollectionViewLayoutAttributes
          else { continue }

        if itemAttribute.representedElementKind == UICollectionElementKindSectionHeader {
          itemAttribute.zIndex = 1024
          itemAttribute.frame.size.height = headerReferenceSize.height
          itemAttribute.frame.origin.x = collectionView.contentOffset.x
          attributes.append(itemAttribute)
        } else {
          itemAttribute.size = spot.sizeForItem(at: itemAttribute.indexPath)

          if scrollDirection == .horizontal {
            itemAttribute.frame.origin.y = headerReferenceSize.height
            itemAttribute.frame.origin.x = offset
            offset += itemAttribute.size.width + minimumInteritemSpacing
          } else {
            itemAttribute.frame.origin.y = itemAttribute.frame.origin.y + headerReferenceSize.height
            itemAttribute.frame.origin.x = itemAttribute.frame.origin.x
          }
          attributes.append(itemAttribute)
        }
      }
    }

    if let y = yOffset, headerReferenceSize.height > 0.0 {
      collectionView.frame.origin.y = y
    }

    return attributes
  }


  /// Asks the layout object if the new bounds require a layout update.
  ///
  /// - parameter newBounds: The new bounds of the collection view.
  ///
  /// - returns: Always returns true
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
}
