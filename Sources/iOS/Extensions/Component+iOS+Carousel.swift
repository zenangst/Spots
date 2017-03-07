import UIKit
import Tailor

internal extension Component {

  func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let layout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionView.isScrollEnabled = true
    layout.scrollDirection = .horizontal
    #if os(iOS)
      collectionView.isPagingEnabled = model.interaction.paginate == .page
    #endif
    configurePageControl()

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      var newCollectionViewHeight: CGFloat = 0.0

      newCollectionViewHeight <- model.items.sorted(by: {
        $0.size.height > $1.size.height
      }).first?.size.height

      collectionView.frame.size.height = newCollectionViewHeight

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    configureCollectionViewHeader(collectionView, with: size)

    CarouselComponent.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    if let componentLayout = model.layout {
      collectionView.frame.size.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }

    if let pageIndicatorPlacement = model.layout?.pageIndicatorPlacement {
      switch pageIndicatorPlacement {
      case .below:
        layout.sectionInset.bottom += pageControl.frame.height
        pageControl.frame.origin.y = collectionView.frame.height
      case .overlay:
        let verticalAdjustment = CGFloat(2)
        pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height - verticalAdjustment
      }
    }
  }

  func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
    collectionView.frame.size.height = collectionViewLayout.contentSize.height
  }
}
