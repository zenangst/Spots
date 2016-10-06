import UIKit
import Brick

/// A scroll view extension on CarouselSpot to handle scrolling specifically for this object.
extension CarouselSpot: UIScrollViewDelegate {

  /// A method that handles what type of scrollling the CarouselSpot should use when pagination is enabled.
  /// It can snap to the nearest item or scroll page by page.
  fileprivate func paginatedEndScrolling() {
    var currentCellOffset = collectionView.contentOffset
    #if os(iOS)
    if paginateByItem {
      currentCellOffset.x += collectionView.frame.size.width / 2
    } else {
      if pageControl.currentPage == 0 {
        currentCellOffset.x = collectionView.frame.size.width / 2
      } else {
        currentCellOffset.x = (collectionView.frame.size.width * CGFloat(pageControl.currentPage)) + collectionView.frame.size.width / 2
        currentCellOffset.x += layout.sectionInset.left * CGFloat(pageControl.currentPage)
      }
    }
    #endif

    if let indexPath = collectionView.indexPathForItem(at: currentCellOffset) {
      collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    } else {
      currentCellOffset.x += layout.sectionInset.left
      if let indexPath = collectionView.indexPathForItem(at: currentCellOffset) {
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
      }
    }
  }

  /// Tells the delegate when the user scrolls the content view within the receiver.
  ///
  /// - parameter scrollView: The scroll-view object in which the scrolling occurred.
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    carouselScrollDelegate?.spotDidScroll(self)
  }

  #if os(iOS)
  /// Tells the delegate when dragging ended in the scroll view.
  ///
  /// - parameter scrollView: The scroll-view object that finished scrolling the content view.
  /// - parameter decelerate: true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard paginate else { return }
    paginatedEndScrolling()
  }
  #endif

  /// Tells the delegate when the user finishes scrolling the content.
  ///
  /// - parameter scrollView:          The scroll-view object where the user ended the touch.
  /// - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
  /// - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    #if os(iOS)
      guard paginate else { return }
    #endif

    let pageWidth: CGFloat = collectionView.frame.size.width
    let currentOffset = scrollView.contentOffset.x
    let targetOffset = targetContentOffset.pointee.x

    var newTargetOffset: CGFloat = targetOffset > currentOffset
      ? ceil(currentOffset / pageWidth) * pageWidth
      : floor(currentOffset / pageWidth) * pageWidth

    if newTargetOffset > scrollView.contentSize.width {
      newTargetOffset = scrollView.contentSize.width
    } else if newTargetOffset < 0 {
      newTargetOffset = 0
    }

    let index: Int = Int(floor(newTargetOffset * CGFloat(items.count) / scrollView.contentSize.width))

    if index >= 0 && index <= items.count {
      carouselScrollDelegate?.spotDidEndScrolling(self, item: items[index])
    }

    let floatIndex = ceil(CGFloat(index) / CGFloat(component.span))

    #if os(iOS)
      pageControl.currentPage = Int(floatIndex)
    #endif

    paginatedEndScrolling()
  }

  /// Scroll to a specific item based on predicate.
  ///
  /// - parameter predicate: A predicate closure to determine which item to scroll to
  public func scrollTo(_ predicate: (Item) -> Bool) {
    if let index = items.index(where: predicate) {
      let pageWidth: CGFloat = collectionView.frame.size.width - layout.sectionInset.right
        + layout.sectionInset.left

      collectionView.setContentOffset(CGPoint(x: pageWidth * CGFloat(index), y:0), animated: true)
    }
  }
}
