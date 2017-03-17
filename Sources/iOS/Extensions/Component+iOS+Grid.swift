import UIKit

extension Component {

  func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard collectionView.collectionViewLayout is GridableLayout else {
      return
    }

    configureCollectionViewHeader(collectionView, with: size)
  }

  func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()
    collectionView.frame.size = collectionViewLayout.collectionViewContentSize
  }
}
