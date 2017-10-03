import UIKit

/// The scroll view manager handles positioning of the header and footer view
/// while scrolling. It also handles constraining horizontal components to not
/// be vertically scrollable.
class ScrollViewManager {

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
