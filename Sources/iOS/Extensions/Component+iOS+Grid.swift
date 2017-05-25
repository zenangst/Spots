import UIKit

extension Component {

  func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? ComponentFlowLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    if collectionViewLayout.collectionViewContentSize.height > UIScreen.main.bounds.height {
      collectionView.frame.size.width = collectionViewLayout.collectionViewContentSize.width
      collectionView.frame.size.height = UIScreen.main.bounds.size.height
    } else {
      collectionView.frame.size = collectionViewLayout.collectionViewContentSize
    }
  }
}
