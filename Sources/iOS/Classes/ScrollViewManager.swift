import UIKit

/// The scroll view manager handles positioning of the header and footer view
/// while scrolling. It also handles constraining horizontal components to not
/// be vertically scrollable.
class ScrollViewManager {

  /// Constrain the Y offset of horizontal components.
  /// This method is only invoked when the user scrolls the component.
  ///
  /// - Parameters:
  ///   - scrollView: The scroll view of the component that should be constrained.
  func constrainScrollViewYOffset(_ scrollView: UIScrollView, parentScrollView: UIScrollView? = nil) {
    let isScrolling = scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating

    guard isScrolling else {
      return
    }

    guard let parentScrollView = parentScrollView else {
      return
    }

    let constrainedY = scrollView.contentSize.height - scrollView.frame.size.height

    guard scrollView.contentSize.height > scrollView.frame.size.height else {
      return
    }

    // The scroll view is located at the top of its parent and does not have its full size.
    // Use computed constrainted Y offset instead of allowing the user to scroll vertically.
    if parentScrollView.contentOffset.y >= scrollView.frame.origin.y {
      scrollView.contentOffset.y = constrainedY
    } else {
      // The scroll view is not fully visible and located at the end of its parent.
      scrollView.contentOffset.y = 0.0
    }
  }

  /// Position the header view according to configuration of the component model.
  ///
  /// - Parameters:
  ///   - headerView: The header view that is used on the component.
  ///   - footerView: The footer view for the component, this is used if the header is set to be sticky.
  ///   - scrollView: The scroll view that the header and footer views belong to.
  ///   - layout: An optional layout struct that determines the layout configuration for the component.
  func positionHeaderView(_ headerView: UIView, footerView: UIView? = nil, in scrollView: UIScrollView, with layout: Layout?) {
    if let layout = layout {
      switch layout.headerMode {
      case .sticky:
        headerView.frame.origin.x = scrollView.contentOffset.x
        if let footerView = footerView {
          let footerFrame = scrollView.convert(footerView.frame, to: scrollView)

          if headerView.frame.intersects(footerFrame) && scrollView.contentOffset.y >= headerView.frame.origin.y {
            break
          }
        }

        headerView.frame.origin.y = scrollView.contentOffset.y
      case .default:
        headerView.frame.origin.x = 0
        headerView.frame.origin.y = -scrollView.contentOffset.y
      }
    } else {
      headerView.frame.origin.y = -scrollView.contentOffset.y
    }
  }

  /// Position the footer view inside of the scroll view.
  ///
  /// - Parameters:
  ///   - footerView: The footer view that should be positioned.
  ///   - scrollView: The scroll view that the footer view belongs to.
  func positionFooterView(_ footerView: UIView, in scrollView: UIScrollView) {
    if scrollView.frame.size.height > scrollView.contentSize.height {
      footerView.frame.origin.y = scrollView.frame.height - footerView.frame.size.height
    } else {
      footerView.frame.origin.y = scrollView.contentSize.height - footerView.frame.size.height
    }
    footerView.frame.origin.x = scrollView.contentOffset.x
  }
}
