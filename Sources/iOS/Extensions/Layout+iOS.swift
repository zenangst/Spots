import UIKit

extension Layout {

  public func configure(spot: Gridable) {
    spot.layout.sectionInset = UIEdgeInsets(
      top: CGFloat(inset.top),
      left: CGFloat(inset.left),
      bottom: CGFloat(inset.bottom),
      right: CGFloat(inset.right)
    )

    spot.layout.minimumInteritemSpacing = CGFloat(itemSpacing)
    spot.layout.minimumLineSpacing = CGFloat(lineSpacing)
  }

  public func configure(collectionViewLayout: CollectionLayout) {
    collectionViewLayout.sectionInset = UIEdgeInsets(
      top: CGFloat(inset.top),
      left: CGFloat(inset.left),
      bottom: CGFloat(inset.bottom),
      right: CGFloat(inset.right)
    )

    collectionViewLayout.minimumInteritemSpacing = CGFloat(itemSpacing)
    collectionViewLayout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
