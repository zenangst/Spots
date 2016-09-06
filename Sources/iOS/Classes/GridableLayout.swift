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
    } else {
      contentSize.height = adapter.spot.items.reduce(0, combine: { $0 + $1.size.height })
      if adapter.spot.component.span > 1 {
        contentSize.height += CGFloat(adapter.spot.items.count) * sectionInset.bottom
        contentSize.height /= adapter.spot.component.span
        contentSize.height += sectionInset.top
      }
    }
  }

  public override func invalidateLayout() {
    super.invalidateLayout()

    guard let collectionView = collectionView else { return }

    if let y = yOffset where collectionView.dragging {
      collectionView.frame.origin.y = y
    }
  }

  public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let adapter = collectionView?.dataSource as? CollectionAdapter else { return nil }

    var attributes = [UICollectionViewLayoutAttributes]()
    var offset: CGFloat = sectionInset.left

    if let newAttributes = super.layoutAttributesForElementsInRect(rect) {

      for attribute in newAttributes {
        if attribute.representedElementKind == UICollectionElementKindSectionHeader {
          attribute.zIndex = 1024
          attribute.frame.size.height = headerReferenceSize.height
          attribute.frame.origin.x = collectionView?.contentOffset.x ?? 0.0
          attributes.append(attribute)
        } else if attribute.representedElementKind == nil {
          attribute.size = adapter.spot.sizeForItemAt(attribute.indexPath)

          if scrollDirection == .Horizontal {
            attribute.frame.origin.y = headerReferenceSize.height
            attribute.frame.origin.x = offset
          } else {
            attribute.frame.origin.y = attribute.frame.origin.y + headerReferenceSize.height
            attribute.frame.origin.x = attribute.frame.origin.x
          }

          attributes.append(attribute)
          offset += attribute.size.width + minimumInteritemSpacing
        }
      }
    }

    if let y = yOffset {
      collectionView?.frame.origin.y = y
    }

    return attributes
  }

  public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
}
