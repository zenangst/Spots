import UIKit

/// A scroll view extension on CarouselComponent to handle scrolling specifically for this object.
extension Delegate: UIScrollViewDelegate {
  #if os(iOS)
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if let spotsScrollView = scrollView.superview?.superview as? SpotsScrollView {
      let spotsScrollGesture = spotsScrollView.panGestureRecognizer
      let componentGesture = scrollView.panGestureRecognizer
      let spotsScrollState = spotsScrollGesture.state
      let componentState = componentGesture.state

      // Let component take precedence and disable scrolling in SpotsScrollView by deactivating
      // its pan gesture. It will be re-enable during the scrolling of the component.
      // See `func scrollViewDidScroll(_ scrollView: UIScrollView)`
      if spotsScrollState == .possible && componentState == .began {
        spotsScrollGesture.isEnabled = false
      } else if componentState == .began && (spotsScrollState == .began || spotsScrollState == .changed) {
        // If the `SpotsScrollView` state is trying to scroll it should take precedence over the component.
        // It usually means that user is trying to scroll either up or down.
        componentGesture.isEnabled = false
      }
    }
  }
  #endif

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    #if os(tvOS)
      // Invoke `scrollViewDidScroll` if there is only one component in the view hierarchy.
      // The reason for this is that if a `SpotsScrollView` has only one component it will not
      // resize to match the entire height of the component but let the components scroll view
      // scroll itself. This is similar to a regular vanilla implementation. To get the regular
      // delegate to work the components scroll view will be used to trigger `didReachBeginning`
      // and `didReachEnd`.
      if let spotsScrollView = scrollView.superview?.superview as? SpotsScrollView, spotsScrollView.subviewsInLayoutOrder.count == 1 {
        (component?.focusDelegate as? SpotsController)?.scrollViewDidScroll(scrollView)
      }
    #endif

    #if os(iOS)
    if let spotsScrollView = scrollView.superview?.superview as? SpotsScrollView {
      spotsScrollView.panGestureRecognizer.isEnabled = true
    }
    #endif

    if let component = component {
      component.backgroundView.frame.origin.x = scrollView.contentOffset.x

      if let footerView = component.footerView {
        scrollViewManager.positionFooterView(footerView, in: scrollView)
      }

      if let headerView = component.headerView {
        scrollViewManager.positionHeaderView(headerView, footerView: component.footerView, in: scrollView, with: component.model.layout)
      }
    }

    performPaginatedScrolling { component, _, _ in
      component.carouselScrollDelegate?.componentCarouselDidScroll(component)
      if component.model.layout.pageIndicatorPlacement == .overlay {
        component.pageControl.frame.origin.x = scrollView.contentOffset.x
      }
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    component?.didScrollHorizontally { component in
      let itemIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)

      guard itemIndex >= 0 else {
        return
      }

      guard itemIndex < component.model.items.count else {
        return
      }

      component.pageControl.currentPage = itemIndex

      guard needsInfiniteScrollingAlignment && component.model.interaction.paginate == .item else {
        return
      }

      performPaginatedScrolling { _, collectionView, collectionViewLayout in
        let centerIndexPath = getCenterIndexPath(in: collectionView,
                                                 scrollView: scrollView,
                                                 point: scrollView.contentOffset,
                                                 contentSize: collectionViewLayout.contentSize,
                                                 offset: collectionViewLayout.minimumInteritemSpacing)

        guard let foundCenterIndex = centerIndexPath else {
          return
        }

        let itemFrame = collectionViewLayout.cachedFrames[foundCenterIndex.item]
        let alignedX = itemFrame.midX - scrollView.frame.size.width / 2
        scrollView.setContentOffset(.init(x: alignedX, y: 0), animated: true)
        needsInfiniteScrollingAlignment = false
      }
    }
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    performPaginatedScrolling { component, collectionView, collectionViewLayout in
      let centerIndexPath = getCenterIndexPath(in: collectionView,
                                               scrollView: scrollView,
                                               point: scrollView.contentOffset,
                                               contentSize: collectionViewLayout.contentSize,
                                               offset: collectionViewLayout.minimumInteritemSpacing)

      guard let foundCenterIndex = centerIndexPath else {
        return
      }

      guard let item = component.item(at: foundCenterIndex.item) else {
        return
      }

      component.carouselScrollDelegate?.componentCarouselDidEndScrolling(component, item: item, animated: true)
    }
  }

  /// Tells the delegate when the user finishes scrolling the content.
  ///
  /// - parameter scrollView:          The scroll-view object where the user ended the touch.
  /// - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
  /// - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    performPaginatedScrolling { component, collectionView, collectionViewLayout in
      var centerIndexPath: IndexPath?

      centerIndexPath = getCenterIndexPath(in: collectionView,
                                           scrollView: scrollView,
                                           point: targetContentOffset.pointee,
                                           contentSize: collectionViewLayout.contentSize,
                                           offset: collectionViewLayout.minimumInteritemSpacing)

      if component.model.interaction.paginate == .page {
        let widthBounds = scrollView.contentSize.width - scrollView.frame.size.width
        let isBeyondBounds = targetContentOffset.pointee.x >= widthBounds && centerIndexPath == nil

        if isBeyondBounds {
          centerIndexPath = IndexPath(item: component.model.items.count - 1, section: 0)
        }
      }

      guard let foundIndexPath = centerIndexPath else {
          return
      }

      if let item = component.item(at: foundIndexPath.item) {
        component.carouselScrollDelegate?.componentCarouselDidEndScrolling(component, item: item, animated: false)
      }

      var newPointeeX: CGFloat = targetContentOffset.pointee.x
      if component.model.interaction.paginate == .item {
        let itemFrame = collectionViewLayout.cachedFrames[foundIndexPath.item]
        newPointeeX = itemFrame.midX - scrollView.frame.size.width / 2
        // Only snap to item if new value exceeds zero or that the index path
        // at center is larger than zero.
        guard (newPointeeX > 0 && foundIndexPath.item > 0) || component.model.layout.infiniteScrolling else {
          return
        }

        let widthBounds = scrollView.contentSize.width - scrollView.frame.size.width
        if component.model.layout.infiniteScrolling, (newPointeeX == 0 || newPointeeX == widthBounds) {
          needsInfiniteScrollingAlignment = true
        }
        targetContentOffset.pointee.x = newPointeeX
      }
    }
  }

  fileprivate func performPaginatedScrolling(_ handler: (Component, UICollectionView, CollectionLayout) -> Void) {
    component?.didScrollHorizontally { component in
      guard let collectionView = component.userInterface as? CollectionView,
        let collectionViewLayout = collectionView.collectionViewLayout as? CollectionLayout else {
          return
      }

      collectionView.contentOffset.y = 0

      handler(component, collectionView, collectionViewLayout)
    }
  }

  func getCenterIndexPath(in collectionView: UICollectionView, scrollView: UIScrollView, point: CGPoint, contentSize: CGSize, offset: CGFloat) -> IndexPath? {
    guard point.x > 0.0 else {
      return IndexPath(item: 0, section: 0)
    }

    let pointXUpperBound = round(contentSize.width - scrollView.frame.width / 2)
    var point = point
    point.x += scrollView.frame.width / 2
    point.y = scrollView.contentSize.height / 2
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
