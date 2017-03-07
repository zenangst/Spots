import UIKit

/// A scroll view extension on CarouselComponent to handle scrolling specifically for this object.
extension Delegate: UIScrollViewDelegate {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    performPaginatedScrolling { spot, collectionView, _ in
      /// This will restrict the scroll view to only scroll horizontally.
      let constrainedYOffset = collectionView.contentSize.height - collectionView.frame.size.height
      if constrainedYOffset >= 0.0 {
        collectionView.contentOffset.y = constrainedYOffset
      }

      switch spot {
      case let spot as Component:
        spot.carouselScrollDelegate?.spotableCarouselDidScroll(spot)
        if spot.model.layout?.pageIndicatorPlacement == .overlay {
          spot.pageControl.frame.origin.x = scrollView.contentOffset.x
        }
      case let spot as CarouselComponent:
        spot.carouselScrollDelegate?.spotableCarouselDidScroll(spot)
        if spot.model.layout?.pageIndicatorPlacement == .overlay {
          spot.pageControl.frame.origin.x = scrollView.contentOffset.x
        }
      default:
        assertionFailure("CoreComponent object is not eligible for horizontal scrolling.")
      }
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    component?.didScrollHorizontally { spot in
      let itemIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)

      guard itemIndex >= 0 else {
        return
      }

      guard itemIndex < spot.items.count else {
        return
      }

      spot.pageControl.currentPage = itemIndex
    }
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    performPaginatedScrolling { spot, collectionView, collectionViewLayout in
      let centerIndexPath = getCenterIndexPath(in: collectionView,
                                               scrollView: scrollView,
                                               point: scrollView.contentOffset,
                                               contentSize: collectionViewLayout.contentSize,
                                               offset: collectionViewLayout.minimumInteritemSpacing)

      guard let foundCenterIndex = centerIndexPath else {
        return
      }

      guard let item = spot.item(at: foundCenterIndex.item) else {
        return
      }

      spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: true)
    }
  }

  /// Tells the delegate when the user finishes scrolling the content.
  ///
  /// - parameter scrollView:          The scroll-view object where the user ended the touch.
  /// - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
  /// - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    performPaginatedScrolling { spot, collectionView, collectionViewLayout in
      var centerIndexPath: IndexPath?

      centerIndexPath = getCenterIndexPath(in: collectionView,
                                           scrollView: scrollView,
                                           point: targetContentOffset.pointee,
                                           contentSize: collectionViewLayout.contentSize,
                                           offset: collectionViewLayout.minimumInteritemSpacing)

      if spot.model.interaction.paginate == .page {
        let widthBounds = scrollView.contentSize.width - scrollView.frame.size.width
        let isBeyondBounds = targetContentOffset.pointee.x >= widthBounds && centerIndexPath == nil

        if isBeyondBounds {
          centerIndexPath = IndexPath(item: spot.items.count - 1, section: 0)
        }
      }

      guard let foundIndexPath = centerIndexPath else {
        return
      }

      guard let centerLayoutAttributes = collectionViewLayout.layoutAttributesForItem(at: foundIndexPath) else {
        return
      }

      if let item = spot.item(at: foundIndexPath.item) {
        spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: false)
      }

      targetContentOffset.pointee.x = centerLayoutAttributes.frame.midX - scrollView.frame.width / 2
    }
  }

  fileprivate func performPaginatedScrolling(_ handler: (ComponentHorizontallyScrollable, UICollectionView, CollectionLayout) -> Void) {
    component?.didScrollHorizontally { spot in
      guard let collectionView = spot.userInterface as? CollectionView,
        let collectionViewLayout = collectionView.collectionViewLayout as? CollectionLayout else {
          return
      }

      handler(spot, collectionView, collectionViewLayout)
    }
  }

  fileprivate func getCenterIndexPath(in collectionView: UICollectionView, scrollView: UIScrollView, point: CGPoint, contentSize: CGSize, offset: CGFloat) -> IndexPath? {
    let pointXUpperBound = round(contentSize.width - scrollView.frame.width / 2)
    var point = point
    point.x += scrollView.frame.width / 2
    point.y = scrollView.frame.height / 2
    var indexPath: IndexPath?

    while indexPath == nil && point.x < pointXUpperBound {
      indexPath = collectionView.indexPathForItem(at: point)
      point.x += max(offset, 1)
    }

    guard let centerIndexPath = indexPath else {
      return nil
    }

    return centerIndexPath
  }
}
