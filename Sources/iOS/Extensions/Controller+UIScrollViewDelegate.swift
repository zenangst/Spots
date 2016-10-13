import UIKit

/**
 A Controller extension to handle scrollViewDidScroll
 */
extension Controller {

  /// Tells the delegate when the user scrolls the content view within the receiver.
  ///
  /// - parameter scrollView: The scroll-view object in which the scrolling occurred.

  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

    guard let delegate = scrollDelegate else { return }

    // Scroll did reach top
    if scrollView.contentOffset.y < 0 &&
      abs(scrollView.contentOffset.y) == scrollView.contentInset.top &&
      !refreshing {
      refreshing = true
      delegate.didReachBeginning(in: scrollView) {
        self.refreshing = false
      }
    }

    if shouldFetch {
      // Infinite scrolling
      refreshPositions.append(size.height - itemOffset)
      refreshing = true
      delegate.didReachEnd(in: scrollView) {
        self.refreshing = false
      }
    }
  }
}
