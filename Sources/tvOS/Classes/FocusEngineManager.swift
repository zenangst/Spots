import UIKit

class FocusEngineManager {
  weak var lastFocusedComponent: Component?

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
    defer {
      lastFocusedComponent = component
    }

    let contentInsetTop: CGFloat = contentInset(for: scrollView).top
    let hasReachedTop = component.model.index == 0 && (component.model.kind == .carousel || itemIndex < Int(component.model.layout.span))
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

