import UIKit

extension Component {

  func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? ComponentFlowLayout else {
      return
    }

    collectionView.isScrollEnabled = true
    collectionViewLayout.scrollDirection = .horizontal
    #if os(iOS)
      collectionView.isPagingEnabled = model.interaction.paginate == .page
    #endif
    configurePageControl()

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      let newCollectionViewHeight: CGFloat = model.items.sorted(by: { $0.size.height > $1.size.height }).first?.size.height ?? 0.0
      collectionView.frame.size.height = newCollectionViewHeight

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += collectionViewLayout.sectionInset.top + collectionViewLayout.sectionInset.bottom
      }
    }

    if let componentLayout = model.layout {
      collectionView.frame.size.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }
  }

  func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? ComponentFlowLayout else {
      return
    }

    // This fixes a constraints warning when trying to prepare a collection view
    // before it has gotten its initial frame.
    if collectionViewLayout.contentSize.height < collectionView.frame.size.height {
      collectionView.frame.size.height = computedHeight
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
    collectionView.frame.size.height = computedHeight

    configurePageControl(collectionView: collectionView, collectionViewLayout: collectionViewLayout)
  }

  private func configurePageControl(collectionView: UICollectionView, collectionViewLayout: UICollectionViewFlowLayout) {
    guard let pageIndicatorPlacement = model.layout?.pageIndicatorPlacement else {
      return
    }

    switch pageIndicatorPlacement {
    case .below:
      collectionViewLayout.sectionInset.bottom += pageControl.frame.height
      pageControl.frame.origin.y = collectionView.frame.height
    case .overlay:
      let verticalAdjustment = CGFloat(2)
      pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height - verticalAdjustment
    }
  }
}
