import UIKit
import Sugar

extension SpotsController {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let bounds = scrollView.bounds
    let inset = scrollView.contentInset
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let itemOffset = (size.height - UIScreen.mainScreen().bounds.size.height * 2) > 0
      ? UIScreen.mainScreen().bounds.size.height * 2
      : (spots.last?.component.items.last?.size.height ?? 0) * 6
    let shouldFetch = offset.y + bounds.size.height - inset.bottom > size.height - itemOffset &&
      size.height > bounds.size.height &&
      !refreshing &&
      size.height - itemOffset > 0 &&
      !refreshPositions.contains(size.height - itemOffset) &&
      offset.y > 0

    // Refreshable
    tableView.contentOffset.y = scrollView.contentOffset.y + tableView.frame.height

    if let customContentInset = spotsScrollView.customContentInset {
      spotsScrollView.contentInset = customContentInset
    }

    if !tableView.hidden && scrollView.contentOffset.y < tableView.frame.origin.y * 2 && !refreshControl.refreshing {
      dispatch {
        self.refreshControl.beginRefreshing()
      }
    }

    // Infinite scrolling
    guard let delegate = spotsScrollDelegate where shouldFetch else { return }

    refreshPositions.append(size.height - itemOffset)
    refreshing = true
    delegate.spotDidReachEnd {
      self.refreshing = false
    }
  }

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.refreshing else { return }
    spotsScrollView.contentInset.top = -scrollView.contentOffset.y

    refreshPositions.removeAll()
    delay(0.5) {
      self.spotsRefreshDelegate?.spotsDidReload(self.refreshControl) { [weak self] in
        guard let weakSelf = self else { return }
        UIView.animateWithDuration(0.3, animations: {
          var newContentInset = weakSelf.initialContentInset

          if let navigationController = weakSelf.navigationController
            where !navigationController.navigationBar.opaque {
              newContentInset.top = navigationController.navigationBar.frame.height + 20
          }

          weakSelf.spotsScrollView.contentInset = newContentInset
          }, completion: { _ in
            weakSelf.refreshing = false
        })
      }
    }
  }
}
