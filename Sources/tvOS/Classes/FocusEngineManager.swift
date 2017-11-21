import UIKit

class FocusEngineManager {
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
    let contentInsetTop: CGFloat = contentInset(for: scrollView).top
    let isFirstComponent = component.model.index == 0
    let firstRowItemIsFocused = component.model.kind == .carousel || itemIndex < Int(component.model.layout.span)
    let hasReachedTop = isFirstComponent && firstRowItemIsFocused

    if hasReachedTop {
      targetContentOffset.pointee.y = -contentInsetTop
      return
    }

    let direction = Direction.determine(lhs: scrollView.contentOffset,
                                        rhs: targetContentOffset.pointee)

    if direction == .up {
      var result: CGFloat = 0
      if let cell: UIView = component.userInterface!.cell(at: itemIndex) {
        if let spotsScrollView = scrollView as? SpotsScrollView,
          let yPosition = spotsScrollView.sizeCache[component.model.index] {
          result = yPosition + cell.frame.origin.y - contentInsetTop

          if component.model.kind == .grid {
            result -= CGFloat(component.model.layout.inset.top + component.model.layout.lineSpacing)
          }
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
