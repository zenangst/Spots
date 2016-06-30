import Cocoa

class CollectionViewLeftLayout: NSCollectionViewFlowLayout {

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [NSCollectionViewLayoutAttributes] {

    let defaultAttributes = super.layoutAttributesForElementsInRect(rect)

    guard !defaultAttributes.isEmpty else { return defaultAttributes }

    var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

    var x: CGFloat = 0
    var y: CGFloat = 0
    for attributes in defaultAttributes {
      if attributes.frame.origin.y != y {
        x = sectionInset.left
        y = attributes.frame.origin.y
      }

      x += attributes.frame.size.width
      leftAlignedAttributes.append(attributes)
    }

    return leftAlignedAttributes
  }
}
