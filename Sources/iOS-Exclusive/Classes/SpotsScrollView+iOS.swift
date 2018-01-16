import CoreGraphics
import UIKit

extension SpotsScrollView {
  /// Layout views in linear order based of view index in `subviewsInLayoutOrder`
  public func layoutViews() {
    componentsView.frame = bounds
    componentsView.bounds = CGRect(origin: contentOffset, size: bounds.size)

    var yOffsetOfCurrentSubview: CGFloat = 0.0
    let lastView = subviewsInLayoutOrder.last

    for (offset, subview) in subviewsInLayoutOrder.enumerated() {
      defer {
          sizeCache[offset] = yOffsetOfCurrentSubview
      }

      if let scrollView = subview as? UIScrollView {
        var frame = scrollView.frame
        var contentOffset = scrollView.contentOffset

        if self.contentOffset.y < yOffsetOfCurrentSubview {
          contentOffset.y = 0.0
          frame.origin.y = yOffsetOfCurrentSubview
        } else {
          contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview
          frame.origin.y = self.contentOffset.y
        }

        let remainingBoundsHeight = fmax(bounds.maxY - frame.minY, 0.0)
        let remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0)

        if configuration.stretchLastComponent && scrollView.isEqual(lastView) {
          let newHeight = self.frame.size.height - scrollView.frame.origin.y + self.contentOffset.y
          frame.size.height = newHeight
        } else {
          frame.size.height = ceil(fmin(remainingBoundsHeight, remainingContentHeight))
        }

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

        if !isRotating {
          scrollView.frame = frame
        }

        scrollView.contentOffset = CGPoint(x: Int(contentOffset.x), y: Int(contentOffset.y))
        yOffsetOfCurrentSubview += scrollView.contentSize.height
      } else {
        var frame = subview.frame
        frame.origin.x = 0
        frame.origin.y = yOffsetOfCurrentSubview
        subview.frame = frame

        yOffsetOfCurrentSubview += frame.size.height
      }
    }
  }
}
