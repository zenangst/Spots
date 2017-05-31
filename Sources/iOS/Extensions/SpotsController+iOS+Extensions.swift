import UIKit

extension SpotsController {

  #if os(iOS)
  /// Refresh all components and reset all refresh positions.
  ///
  /// - Parameter refreshControl: A UIRefreshControl.
  public func refreshComponents(_ refreshControl: UIRefreshControl) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.refreshPositions.removeAll()

      strongSelf.refreshDelegate?.componentsDidReload(strongSelf.components, refreshControl: refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif

  /// Scroll to the index of a Component object, only available on iOS.
  ///
  /// - parameter index:          The index of the component that you want to scroll
  /// - parameter includeElement: A filter predicate to find a view model
  public func scrollTo(componentIndex index: Int = 0, includeElement: (Item) -> Bool) {
    guard let itemY = component(at: index)?.itemOffset(includeElement) else {
      return
    }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += components[0..<index].reduce(0, { $0 + $1.computedHeight })
    }

    guard let computedHeight = component(at: index)?.computedHeight else {
      return
    }

    if computedHeight > scrollView.frame.height - scrollView.contentInset.bottom - initialHeight {
      let y = itemY - scrollView.frame.size.height + scrollView.contentInset.bottom + initialHeight
      scrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /// Scroll to the bottom of the controller
  ///
  /// - parameter animated: A boolean in indicate if the scrolling should be done with animation.
  public func scrollToBottom(_ animated: Bool) {
    let y = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom
    scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
}
