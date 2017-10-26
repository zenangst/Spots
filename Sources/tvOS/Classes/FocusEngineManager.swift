import UIKit

class FocusEngineManager {
  weak var lastFocusedComponent: Component?
  var lastOffset: CGFloat = 0.0

  enum Direction {
    case up, down, noscroll
    static func determine(lhs: CGPoint, rhs: CGPoint) -> Direction {
      if lhs.y < rhs.y {
        return .down
      } else if lhs.y > rhs.y {
        return .up
      } else {
        return .noscroll
      }
    }
  }

  func handleScrolling(in scrollView: ScrollView, for component: Component, itemIndex: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    switch component.model.kind {
    case .carousel:
      handleHorizontalComponent(in: scrollView, for: component, itemIndex: itemIndex, targetContentOffset: targetContentOffset)
    case .grid:
      handleVerticalComponent(in: scrollView, for: component, itemIndex: itemIndex, targetContentOffset: targetContentOffset)
    default:
      break
    }

    lastFocusedComponent = component
  }

  private func handleHorizontalComponent(in scrollView: ScrollView, for component: Component, itemIndex: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let frameCache = (component.collectionView?.collectionViewLayout as? ComponentFlowLayout)?.cachedFrames
    let itemSize = component.item(at: itemIndex)!.size
    var itemOffset = itemSize.height

    if let frameCache = frameCache, itemIndex < frameCache.count {
      itemOffset = frameCache[itemIndex].maxY
    }

    // Don't invoke this behavior if the pointee is the same as the scroll views content offset.
    guard scrollView.contentOffset != targetContentOffset.pointee else {
      return
    }

    // Reached the end of the screen.
    let maximumContentOffset = scrollView.contentSize.height - scrollView.frame.size.height
    if targetContentOffset.pointee.y >= maximumContentOffset {
      targetContentOffset.pointee.y = maximumContentOffset
      return
    }

    let contentInsetTop: CGFloat = contentInset(for: scrollView).top

    // Reached the top
    if component.model.index == 0 {
      if component.model.kind == .carousel {
        targetContentOffset.pointee.y = -contentInsetTop
        return
      } else if component.model.kind == .grid && itemIndex < Int(component.model.layout.span) {
        targetContentOffset.pointee.y = -contentInsetTop
        return
      }
    }

    var layoutOffset = CGFloat(component.model.layout.inset.top + component.model.layout.inset.bottom)
    layoutOffset += component.headerHeight
    layoutOffset += component.footerHeight

    let direction = Direction.determine(lhs: scrollView.contentOffset,
                                        rhs: targetContentOffset.pointee)

    if lastFocusedComponent == component &&
      direction != .noscroll &&
      lastOffset == itemOffset {
      targetContentOffset.pointee.y = scrollView.contentOffset.y
      return
    }

    switch direction {
    case .up:
      targetContentOffset.pointee.y = scrollView.contentOffset.y - itemOffset - layoutOffset
    case .down:
      targetContentOffset.pointee.y = scrollView.contentOffset.y + itemOffset + layoutOffset
    case .noscroll:
      targetContentOffset.pointee.y = scrollView.contentOffset.y
    }

    lastOffset = itemOffset
  }

  private func handleVerticalComponent(in scrollView: ScrollView, for component: Component, itemIndex: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let direction = Direction.determine(lhs: scrollView.contentOffset,
                                        rhs: targetContentOffset.pointee)
    let contentInsetTop: CGFloat = contentInset(for: scrollView).top

    if direction == .up {
      var result: CGFloat = 0
      if let cell: UIView = component.userInterface!.cell(at: itemIndex) {
        if let spotsScrollView = scrollView as? SpotsScrollView,
          let yPosition = spotsScrollView.sizeCache[component.model.index] {
          result = yPosition + cell.frame.origin.y - contentInsetTop
        }
      }

      // Reached the top
      if component.model.index == 0 {
        if component.model.kind == .grid && itemIndex < Int(component.model.layout.span) {
          targetContentOffset.pointee.y = -contentInsetTop
          return
        }
      }

      targetContentOffset.pointee.y = result
    }
  }

  private func contentInset(for scrollView: UIScrollView) -> UIEdgeInsets {
    let contentInset: UIEdgeInsets

    if #available(tvOS 11.0, *) {
      contentInset = scrollView.adjustedContentInset
    } else {
      contentInset = scrollView.contentInset
    }

    return contentInset
  }
}
