import Cocoa

extension Component {

  func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout else {
      return
    }

    collectionView.frame.size.width = size.width
    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    if let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize {
      var collectionViewContentSize = collectionViewContentSize
      collectionViewContentSize.height += headerHeight + footerHeight
      collectionViewContentSize.height += CGFloat(model.layout.inset.top + model.layout.inset.bottom)
      collectionView.frame.size.height = collectionViewContentSize.height
      collectionView.frame.size.width = collectionViewContentSize.width
      scrollView.frame.size.height = collectionView.frame.height
    }
  }

  func resizeVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize, type: ComponentResize) {
    collectionView.collectionViewLayout?.invalidateLayout()

    switch type {
    case .live:
      prepareItems(recreateComposites: false)
      layout(with: size, animated: false)
    case .end:
      layout(with: size, animated: false)
    }
  }
}
