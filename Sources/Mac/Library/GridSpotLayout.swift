import Cocoa

class GridSpotLayout: NSCollectionViewFlowLayout {

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [NSCollectionViewLayoutAttributes] {

    let defaultAttributes = super.layoutAttributesForElementsInRect(rect)

    guard !defaultAttributes.isEmpty else { return defaultAttributes }

    var additionalX = (collectionView?.frame.width ?? 0) - collectionViewContentSize.width
    if additionalX > 0.0 {
      additionalX = additionalX / 2
    } else {
      additionalX = 0
    }

    var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()
    var x = self.sectionInset.left + additionalX
    var lastYPosition = defaultAttributes[0].frame.origin.y

    for attributes in defaultAttributes {
      if attributes.frame.origin.y != lastYPosition {
        x = self.sectionInset.left
        lastYPosition = attributes.frame.origin.y
      }

      attributes.frame.origin.x = x
      x += attributes.frame.size.width + minimumInteritemSpacing

      leftAlignedAttributes.append(attributes)
    }

    return leftAlignedAttributes
  }
}
