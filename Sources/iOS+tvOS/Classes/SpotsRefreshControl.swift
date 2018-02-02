#if os(iOS)
import UIKit

/// A custom refresh control that makes sure that endRefreshing is only called
/// when it is needed.
class SpotsRefreshControl: UIRefreshControl {

  // Must be explicitly called when the refreshing has completed
  override func endRefreshing() {
    // Only call endRefreshing if the refresh control is actually refreshing, otherwise
    // scrolling will be interrupted.
    if isRefreshing {
      super.endRefreshing()
    }
  }
}
#endif
