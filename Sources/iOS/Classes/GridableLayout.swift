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

    guard let adapter = collectionView?.delegate as? CollectionAdapter,
      let firstItem = adapter.spot.items.first else { return }
    contentSize.width = adapter.spot.items.reduce(0, { $0 + $1.size.width })
    contentSize.width += CGFloat(adapter.spot.items.count) * (minimumInteritemSpacing)
    contentSize.width += sectionInset.left + (sectionInset.right / 2) - 3
    contentSize.width = ceil(contentSize.width)

    if scrollDirection == .horizontal {
      contentSize.height = firstItem.size.height + headerReferenceSize.height
      contentSize.height += sectionInset.top + sectionInset.bottom

      if let spot = adapter.spot as? CarouselSpot, spot.pageIndicator {
        contentSize.height += spot.pageControl.frame.height
      }
    } else {
      contentSize.height = adapter.spot.items.reduce(0, { $0 + $1.size.height })
      if adapter.spot.component.span > 1 {
        let count = adapter.spot.items.count
        if let last = adapter.spot.items.last, count % Int(adapter.spot.component.span) != 0 {
          contentSize.height += last.size.height
        }

        contentSize.height += CGFloat(adapter.spot.items.count) * minimumLineSpacing
        contentSize.height /= CGFloat(adapter.spot.component.span)
        contentSize.height += sectionInset.top + sectionInset.bottom
      } else {
        contentSize.height = adapter.spot.items.reduce(0, { $0 + $1.size.height })
        contentSize.height += sectionInset.top + sectionInset.bottom
      }
    }
  }

  open override func invalidateLayout() {
    super.invalidateLayout()

    guard let collectionView = collectionView else { return }

    if let y = yOffset, collectionView.isDragging && headerReferenceSize.height > 0.0 {
      collectionView.frame.origin.y = y
    }
  }

  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView,
      let adapter = collectionView.dataSource as? CollectionAdapter
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
          itemAttribute.size = adapter.spot.sizeForItemAt(itemAttribute.indexPath)

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

  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
}
