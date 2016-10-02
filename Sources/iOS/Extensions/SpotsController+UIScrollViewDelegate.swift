import UIKit

/**
 A SpotsController extension to handle scrollViewDidScroll
 */
extension SpotsController {

  /**
   Tells the delegate when the user scrolls the content view within the receiver.

   - parameter scrollView: The scroll-view object in which the scrolling occurred.
   */
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let multiplier: CGFloat = !refreshPositions.isEmpty
      ? CGFloat(1 + refreshPositions.count)
      : 1
    let itemOffset = (size.height - scrollView.bounds.size.height * 2) > 0
      ? scrollView.bounds.size.height * 2
      : (spots.last?.component.items.last?.size.height ?? 0) * 6
    let shouldFetch = !refreshing &&
      size.height > scrollView.bounds.height &&
      offset.y > size.height - scrollView.bounds.height * multiplier &&
      !refreshPositions.contains(size.height - itemOffset)

    guard let delegate = spotsScrollDelegate else { return }

    // Scroll did reach top
    if scrollView.contentOffset.y < 0 &&
      abs(scrollView.contentOffset.y) == scrollView.contentInset.top &&
      !refreshing {
      refreshing = true
      delegate.spotDidReachBeginning {
        self.refreshing = false
      }
    }

    if shouldFetch {
      // Infinite scrolling
      refreshPositions.append(size.height - itemOffset)
      refreshing = true
      delegate.spotDidReachEnd {
        self.refreshing = false
      }
    }
  }
}
