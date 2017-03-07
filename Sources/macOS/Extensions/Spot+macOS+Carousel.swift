import Cocoa
import Tailor

extension Spot {

  func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    var newCollectionViewHeight: CGFloat = 0.0

    newCollectionViewHeight <- model.items.sorted(by: {
      $0.size.height > $1.size.height
    }).first?.size.height

    scrollView.scrollingEnabled = (model.items.count > 1)
    scrollView.hasHorizontalScroller = (model.items.count > 1)

    collectionView.frame.size.height = newCollectionViewHeight
    CarouselSpot.configure?(collectionView)
  }

  func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    if let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize {
      var newCollectionViewHeight: CGFloat = 0.0

      newCollectionViewHeight <- model.items.sorted(by: {
        $0.size.height > $1.size.height
      }).first?.size.height

      var collectionViewContentSize = collectionViewContentSize

      if let layout = model.layout {
        collectionViewContentSize.width += CGFloat(layout.inset.left)
      }

      collectionView.frame.origin.y = headerHeight
      collectionView.frame.size.width = collectionViewContentSize.width
      collectionView.frame.size.height = newCollectionViewHeight

      documentView.frame.size = collectionView.frame.size

      if let layout = model.layout {
        documentView.frame.size.width += CGFloat(layout.inset.right)
      }

      documentView.frame.size.height = collectionView.frame.size.height + headerHeight + footerHeight

      scrollView.frame.size.width = size.width
      scrollView.frame.size.height = documentView.frame.size.height
      scrollView.scrollerInsets.bottom = footerHeight
    }
  }
}
