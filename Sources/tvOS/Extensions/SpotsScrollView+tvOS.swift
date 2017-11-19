import CoreGraphics
import UIKit

extension SpotsScrollView {
  /// Layout views in linear order based of view index in `subviewsInLayoutOrder`
  func layoutViews() {
    guard let superview = superview else {
      return
    }

    componentsView.frame = bounds
    componentsView.bounds = CGRect(origin: contentOffset, size: bounds.size)

    var yOffsetOfCurrentSubview: CGFloat = 0.0
    let lastView = subviewsInLayoutOrder.last

    for (offset, view) in subviewsInLayoutOrder.enumerated() {
      guard let scrollView = view as? UIScrollView else {
        return
      }

      var frame = scrollView.frame
      var contentOffset = scrollView.contentOffset

      if self.contentOffset.y < yOffsetOfCurrentSubview {
        contentOffset.y = 0.0
        frame.origin.y = yOffsetOfCurrentSubview
      } else {
        contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview
        frame.origin.y = self.contentOffset.y
      }

      sizeCache[offset] = yOffsetOfCurrentSubview
      yOffsetOfCurrentSubview += scrollView.contentSize.height

      let remainingBoundsHeight = fmax(bounds.maxY - frame.minY, 0.0)
      let remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0)
      let calculatedHeight = ceil(fmin(remainingBoundsHeight, remainingContentHeight))

      var newHeight: CGFloat
      if configuration.stretchLastComponent && scrollView.isEqual(lastView) {
        newHeight = self.frame.size.height - scrollView.frame.origin.y + self.contentOffset.y
      } else {
        newHeight = calculatedHeight
      }

      let shouldModifyContentOffset = contentOffset.y < scrollView.frame.size.height || contentOffset.y > scrollView.contentOffset.y

      if let component = (scrollView.delegate as? Delegate)?.component {
        if component.model.kind == .carousel {
          newHeight = fmin(componentsView.frame.height, scrollView.contentSize.height)
          if shouldModifyContentOffset {
            scrollView.contentOffset = CGPoint(x: Int(contentOffset.x), y: Int(contentOffset.y))
          } else {
            scrollView.frame.size.height = newHeight
            continue
          }
        } else if component.model.kind == .grid {
          if subviewsInLayoutOrder.count > 1 {
            if shouldModifyContentOffset {
              scrollView.contentOffset = CGPoint(x: Int(contentOffset.x), y: Int(contentOffset.y))
            }
          }
          newHeight = fmin(componentsView.frame.height, scrollView.contentSize.height)
        }
      }

      frame.size.height = newHeight

      // Using `.integral` can sometimes set the height back to 1.
      // To avoid this we check if the height is zero before we run `.integral`.
      // If it was, then we set it to zero again to not have frame heights jump between
      // one and zero when scrolling. Jump frame heights can cause rendering issues and
      // make `UICollectionView` not render corretly when you use multiple components.
      let shouldResetFrameHeightToZero = frame.size.height == 0
      frame = frame.integral
      if shouldResetFrameHeightToZero {
        frame.size.height = 0
      }

      scrollView.frame = frame
    }

    contentSize = CGSize(width: bounds.size.width, height: yOffsetOfCurrentSubview)

    if self.frame.size.height != superview.frame.size.height {
      self.frame.size.height = superview.frame.size.height
    }
  }
}
