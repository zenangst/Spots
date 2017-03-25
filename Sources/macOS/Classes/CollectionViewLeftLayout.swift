import Cocoa

class CollectionViewLeftLayout: NSCollectionViewFlowLayout {

  override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {

    let defaultAttributes = super.layoutAttributesForElements(in: rect)

    guard !defaultAttributes.isEmpty else { return defaultAttributes }

    var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

    var x: CGFloat = sectionInset.left
    var y: CGFloat = 0
    for attributes in defaultAttributes {
      let attributes = attributes

      if attributes.frame.origin.y != y {
        x = sectionInset.left
        y = attributes.frame.origin.y
      }

      attributes.frame.origin.x = x

      x += attributes.frame.size.width + minimumInteritemSpacing
      leftAlignedAttributes.append(attributes)
    }

    return leftAlignedAttributes
  }
}
