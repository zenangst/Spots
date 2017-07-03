import Cocoa

extension Component {
  func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    let newCollectionViewHeight = calculateCollectionViewHeight()

    collectionView.frame.size.height = newCollectionViewHeight
  }

  func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? FlowLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    guard let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize else {
      return
    }

    let newCollectionViewHeight = calculateCollectionViewHeight()

    collectionView.frame.size.width = collectionViewContentSize.width
    collectionView.frame.size.height = newCollectionViewHeight
    collectionView.frame.size.height += headerHeight

    documentView.frame.size.width = collectionViewContentSize.width
    documentView.frame.size.height = collectionView.frame.size.height + footerHeight

    scrollView.frame.size.width = size.width
    scrollView.frame.size.height = documentView.frame.size.height
    scrollView.scrollerInsets.bottom = footerHeight
  }

  func resizeHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize, type: ComponentResize) {
    prepareItems(recreateComposites: false)
    layout(with: size)
  }

  private func calculateCollectionViewHeight() -> CGFloat {
    var newCollectionViewHeight: CGFloat = model.items.sorted(by: {
      $0.size.height > $1.size.height
    }).first?.size.height ?? 0.0

    if let layout = model.layout {
      newCollectionViewHeight *= CGFloat(layout.itemsPerRow)
      newCollectionViewHeight += CGFloat(layout.inset.top + layout.inset.bottom)

      if layout.itemsPerRow > 1 {
        newCollectionViewHeight += CGFloat(layout.lineSpacing * Double(layout.itemsPerRow - 2))
      }
    }

    return newCollectionViewHeight
  }
}
