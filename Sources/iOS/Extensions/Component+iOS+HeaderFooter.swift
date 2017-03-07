import UIKit

extension Component {

  func configureCollectionViewHeader(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    guard !model.header.isEmpty else {
      return
    }

    guard let view = Configuration.views.make(model.header)?.view as? Componentable else {
      return
    }

    collectionViewLayout.headerReferenceSize.width = collectionView.frame.size.width
    collectionViewLayout.headerReferenceSize.height = view.frame.size.height

    if collectionViewLayout.headerReferenceSize.width == 0.0 {
      collectionViewLayout.headerReferenceSize.width = size.width
    }

    if collectionViewLayout.headerReferenceSize.height == 0.0 {
      collectionViewLayout.headerReferenceSize.height = view.preferredHeaderHeight
    }
  }
}
