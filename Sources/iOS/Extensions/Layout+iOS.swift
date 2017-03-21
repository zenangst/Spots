import UIKit

extension Layout {

  public func configure(component: Component) {
    guard let collectionViewLayout = component.collectionView?.collectionViewLayout as? FlowLayout else {
      return
    }

    collectionViewLayout.sectionInset = UIEdgeInsets(
      top: CGFloat(inset.top),
      left: CGFloat(inset.left),
      bottom: CGFloat(inset.bottom),
      right: CGFloat(inset.right)
    )

    collectionViewLayout.minimumInteritemSpacing = CGFloat(itemSpacing)
    collectionViewLayout.minimumLineSpacing = CGFloat(lineSpacing)
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
