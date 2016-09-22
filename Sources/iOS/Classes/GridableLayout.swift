import UIKit

public class GridableLayout: UICollectionViewFlowLayout {

  var contentSize = CGSize.zero
  public var yOffset: CGFloat?

  public override func collectionViewContentSize() -> CGSize {
    return contentSize
  }

  public override func prepareLayout() {
    super.prepareLayout()

    guard let adapter = collectionView?.delegate as? CollectionAdapter,
      firstItem = adapter.spot.items.first else { return }
    contentSize.width = adapter.spot.items.reduce(0, combine: { $0 + $1.size.width })
    contentSize.width += CGFloat(adapter.spot.items.count) * (minimumInteritemSpacing)
    contentSize.width += sectionInset.left + (sectionInset.right / 2) - 3
    contentSize.width = ceil(contentSize.width)

    if scrollDirection == .Horizontal {
      contentSize.height = firstItem.size.height + headerReferenceSize.height
      contentSize.height += sectionInset.top + sectionInset.bottom

      if let spot = adapter.spot as? CarouselSpot where spot.pageIndicator {
        contentSize.height += spot.pageControl.frame.size.height
      }
    } else {
      contentSize.height = adapter.spot.items.reduce(0, combine: { $0 + $1.size.height })
      if adapter.spot.component.span > 1 {
        let count = adapter.spot.items.count
        if let last = adapter.spot.items.last where count % Int(adapter.spot.component.span) != 0 {
          contentSize.height += last.size.height
        }

        contentSize.height += CGFloat(adapter.spot.items.count) * minimumLineSpacing
        contentSize.height /= adapter.spot.component.span
        contentSize.height += sectionInset.top + sectionInset.bottom
      } else {
        contentSize.height = adapter.spot.items.reduce(0, combine: { $0 + $1.size.height })
        contentSize.height += sectionInset.top + sectionInset.bottom
      }
    }
  }

  public override func invalidateLayout() {
    super.invalidateLayout()

    guard let collectionView = collectionView else { return }

    if let y = yOffset where collectionView.dragging && headerReferenceSize.height > 0.0 {
      collectionView.frame.origin.y = y
    }
  }

  public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView,
      adapter = collectionView.dataSource as? CollectionAdapter
      else { return nil }

    var attributes = [UICollectionViewLayoutAttributes]()
    var rect = CGRect(origin: CGPoint.zero, size: contentSize)

    if headerReferenceSize.height > 0.0 {
      rect.origin = CGPoint(x: -UIScreen.mainScreen().bounds.width, y: 0)
      rect.size.height = contentSize.height
      rect.size.width = UIScreen.mainScreen().bounds.width * 3
    }

    if let newAttributes = super.layoutAttributesForElementsInRect(rect) {
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

          if scrollDirection == .Horizontal {
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

    if let y = yOffset where headerReferenceSize.height > 0.0 {
      collectionView.frame.origin.y = y
    }

    return attributes
  }

  public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
}
