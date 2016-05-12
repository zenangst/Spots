import UIKit
import Sugar

/**
 A SpotsController extension to handle scrollViewDidScroll
 */
extension SpotsController {

  /**
   Tells the delegate when the user scrolls the content view within the receiver.
   
   - Parameter scrollView: The scroll-view object in which the scrolling occurred.
 */
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let itemOffset = (size.height - UIScreen.mainScreen().bounds.size.height * 2) > 0
      ? UIScreen.mainScreen().bounds.size.height * 2
      : (spots.last?.component.items.last?.size.height ?? 0) * 6
    let shouldFetch = !refreshing &&
      size.height > UIScreen.mainScreen().bounds.height &&
      offset.y > size.height - UIScreen.mainScreen().bounds.height * 2 &&
      !refreshPositions.contains(size.height - itemOffset)

    guard let delegate = spotsScrollDelegate else { return }

    // Scroll did reach top
    if spotsScrollView.contentOffset.y < 0 &&
      abs(spotsScrollView.contentOffset.y) == spotsScrollView.contentInset.top &&
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
