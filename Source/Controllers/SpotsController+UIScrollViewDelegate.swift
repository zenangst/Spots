import Sugar

extension SpotsController {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let bounds = scrollView.bounds
    let inset = scrollView.contentInset
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let shouldFetch = offset.y + bounds.size.height - inset.bottom > size.height
      && size.height > bounds.size.height
      && !refreshing

    // Refreshable
    tableView.contentOffset.y = scrollView.contentOffset.y + tableView.frame.height

    if refreshControl.superview != nil && scrollView.contentOffset.y < tableView.frame.origin.y * 2 && !refreshControl.refreshing {
      refreshControl.beginRefreshing()
    }

    // Infinite scrolling
    if shouldFetch && !refreshing {
      refreshing = true
      delay(0.2) {
        self.spotsScrollDelegate?.spotDidReachEnd {
          self.refreshing = false
        }
      }
    }
  }

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.refreshing else { return }
    spotsScrollView.contentInset.top = -scrollView.contentOffset.y

    delay(0.5) {
      self.spotsRefreshDelegate?.spotsDidReload(self.refreshControl) { [weak self] in
        guard let weakSelf = self else { return }
        UIView.animateWithDuration(0.3, animations: {
          weakSelf.spotsScrollView.contentInset = weakSelf.initialContentInset
          }, completion: { _ in
            weakSelf.refreshing = false
        })
      }
    }
  }
}
