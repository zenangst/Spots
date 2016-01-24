import UIKit
import Sugar

extension SpotsController {

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

    // Infinite scrolling
    guard let delegate = spotsScrollDelegate where shouldFetch else { return }
    refreshPositions.append(size.height - itemOffset)
    refreshing = true
    delegate.spotDidReachEnd {
      self.refreshing = false
    }
  }
}
