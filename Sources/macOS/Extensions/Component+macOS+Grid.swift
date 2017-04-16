import Cocoa

extension Component {

  func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    Component.configure?(collectionView)
  }

  func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout else {
      return
    }

    collectionView.frame.origin.y = headerHeight
    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    if let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize {
      var collectionViewContentSize = collectionViewContentSize
      collectionViewContentSize.height += headerHeight + footerHeight
      collectionView.frame.size.height = collectionViewContentSize.height
      collectionView.frame.size.width = collectionViewContentSize.width

      documentView.frame.size = collectionViewContentSize

      scrollView.frame.size.height = collectionView.frame.height
    }
  }

  func resizeCollectionView(_ collectionView: CollectionView, with size: CGSize, type: ComponentResize) {
    switch type {
    case .live:
      layout(with: size)
      prepareItems(clean: false)
    case .end:
      if model.interaction.scrollDirection == .horizontal {
        prepareItems(clean: false)
        layout(with: size)
      } else {
        layout(with: size)
      }
    }
  }
}
