import UIKit

/// A scroll view extension on CarouselSpot to handle scrolling specifically for this object.
extension Delegate: UIScrollViewDelegate {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let spot = spot,
      let collectionView = spot.userInterface as? CollectionView,
      spot.component.interaction.scrollDirection == .horizontal else {
        return
    }

    /// This will restrict the scroll view to only scroll horizontally.
    let constrainedYOffset = collectionView.contentSize.height - collectionView.frame.size.height
    if constrainedYOffset >= 0.0 {
      collectionView.contentOffset.y = constrainedYOffset
    }

    switch spot {
    case let spot as Spot:
      spot.carouselScrollDelegate?.spotableCarouselDidScroll(spot)
      if spot.component.layout?.pageIndicatorPlacement == .overlay {
        spot.pageControl.frame.origin.x = scrollView.contentOffset.x
      }
    case let spot as CarouselSpot:
      spot.carouselScrollDelegate?.spotableCarouselDidScroll(spot)
      if spot.component.layout?.pageIndicatorPlacement == .overlay {
        spot.pageControl.frame.origin.x = scrollView.contentOffset.x
      }
    default:
      break
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let spot = spot, spot.component.interaction.scrollDirection == .horizontal else {
      return
    }

    let itemIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)

    guard itemIndex >= 0 else {
      return
    }

    guard itemIndex < spot.items.count else {
      return
    }

    switch spot {
    case let spot as Spot:
      spot.pageControl.currentPage = itemIndex
    case let spot as CarouselSpot:
      spot.pageControl.currentPage = itemIndex
    default:
      break
    }
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    guard let spot = spot,
      let collectionView = spot.userInterface as? CollectionView,
      let collectionViewLayout = collectionView.collectionViewLayout as? CollectionLayout,
      spot.component.interaction.scrollDirection == .horizontal else {
        return
    }

    #if os(iOS)
      guard spot.component.interaction.paginate == .item else {
        return
      }
    #endif

    guard let centerIndexPath = getCenterIndexPath(in: collectionView,
                                                   scrollView: scrollView,
                                                   point: scrollView.contentOffset,
                                                   contentSize: collectionViewLayout.contentSize,
                                                   offset: collectionViewLayout.minimumInteritemSpacing) else {
                                                    return
    }

    guard let item = spot.item(at: centerIndexPath.item) else {
      return
    }

    switch spot {
    case let spot as CarouselSpot:
      spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: true)
    case let spot as Spot:
      spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: true)
    default:
      break
    }
  }

  /// Tells the delegate when the user finishes scrolling the content.
  ///
  /// - parameter scrollView:          The scroll-view object where the user ended the touch.
  /// - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
  /// - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let spot = spot,
      let collectionView = spot.userInterface as? CollectionView,
      let collectionViewLayout = collectionView.collectionViewLayout as? CollectionLayout,
      spot.component.interaction.scrollDirection == .horizontal else {
        return
    }

    #if os(iOS)
      guard spot.component.interaction.paginate == .item else {
        return
      }
    #endif

    var centerIndexPath: IndexPath?

    centerIndexPath = getCenterIndexPath(in: collectionView,
      scrollView: scrollView,
      point: targetContentOffset.pointee,
      contentSize: collectionViewLayout.contentSize,
      offset: collectionViewLayout.minimumInteritemSpacing)

    let widthBounds = scrollView.contentSize.width - scrollView.frame.size.width
    let isBeyondBounds = targetContentOffset.pointee.x >= widthBounds && centerIndexPath == nil

    if isBeyondBounds {
      centerIndexPath = IndexPath(item: spot.items.count - 1, section: 0)
    }

    guard let foundIndexPath = centerIndexPath else {
      return
    }

    guard let centerLayoutAttributes = collectionViewLayout.layoutAttributesForItem(at: foundIndexPath) else {
      return
    }

    if let item = spot.item(at: foundIndexPath.item) {
      switch spot {
      case let spot as CarouselSpot:
        spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: false)
      case let spot as Spot:
        spot.carouselScrollDelegate?.spotableCarouselDidEndScrolling(spot, item: item, animated: false)
      default:
        break
      }
    }

    targetContentOffset.pointee.x = centerLayoutAttributes.frame.midX - scrollView.frame.width / 2
  }

  fileprivate func getCenterIndexPath(in collectionView: UICollectionView, scrollView: UIScrollView, point: CGPoint, contentSize: CGSize, offset: CGFloat) -> IndexPath? {
    let pointXUpperBound = contentSize.width - scrollView.frame.width / 2
    var point = point
    point.x += scrollView.frame.width / 2
    point.y = scrollView.frame.midY
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
