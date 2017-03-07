import UIKit

extension Spot {

  func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    configureCollectionViewHeader(collectionView, with: size)

    GridSpot.configure?(collectionView, collectionViewLayout)
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
