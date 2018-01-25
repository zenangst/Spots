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
    let multipleComponents = subviewsInLayoutOrder.count > 1
    let scrollViews = subviewsInLayoutOrder.flatMap({ $0 as? ScrollView })

    for (offset, scrollView) in scrollViews.enumerated() {
      defer {
        sizeCache[offset] = yOffsetOfCurrentSubview
        yOffsetOfCurrentSubview += scrollView.contentSize.height
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

      let remainingBoundsHeight = fmax(bounds.maxY - yOffsetOfCurrentSubview, 0.0)
      let remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0)

      var newHeight: CGFloat
      if configuration.stretchLastComponent && scrollView.isEqual(lastView) {
        newHeight = self.frame.size.height - scrollView.frame.origin.y + self.contentOffset.y
      } else {
        newHeight = ceil(fmin(remainingBoundsHeight, remainingContentHeight))
      }

      switch multipleComponents {
      case true:
        let shouldModifyContentOffset = contentOffset.y <= scrollView.contentSize.height
        if (scrollView as? CollectionView)?.flowLayout?.scrollDirection == .horizontal {
          newHeight = fmin(componentsView.frame.height, scrollView.contentSize.height)
        }
        if shouldModifyContentOffset {
          scrollView.contentOffset = CGPoint(x: Int(contentOffset.x), y: Int(contentOffset.y))
        } else {
          frame.origin.y = yOffsetOfCurrentSubview
        }
      case false:
        newHeight = fmin(componentsView.frame.height, scrollView.contentSize.height)
      }

      frame.size.height = newHeight
      scrollView.frame = frame
    }
  }
}
