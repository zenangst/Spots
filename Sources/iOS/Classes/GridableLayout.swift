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
    guard let adapter = collectionView?.delegate as? CollectionAdapter else { return nil }

    var attributes = [UICollectionViewLayoutAttributes]()
    var offset: CGFloat = sectionInset.left

    if let headerAttributes = super.layoutAttributesForElementsInRect(rect)?
      .filter({ $0.representedElementKind == UICollectionElementKindSectionHeader })
      .first {
      headerAttributes.zIndex = 1024
      headerAttributes.frame.size.height = headerReferenceSize.height
      headerAttributes.frame.origin.x = collectionView?.contentOffset.x ?? 0.0
      attributes.append(headerAttributes)
    }

    for item in 0..<adapter.spot.items.count {
      let indexPath = NSIndexPath(forItem: item, inSection: 0)
      guard let itemAttribute = layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes
        else { continue }

      itemAttribute.size = adapter.spot.sizeForItemAt(indexPath)

      if scrollDirection == .Horizontal {
        itemAttribute.frame.origin.y = headerReferenceSize.height
        itemAttribute.frame.origin.x = offset
      } else {
        itemAttribute.frame.origin.y = itemAttribute.frame.origin.y + headerReferenceSize.height
        itemAttribute.frame.origin.x = itemAttribute.frame.origin.x
      }

      attributes.append(itemAttribute)
      offset += itemAttribute.size.width + minimumInteritemSpacing
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
