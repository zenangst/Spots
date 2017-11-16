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
    let isFirstComponent = component.model.index == 0
    let firstRowItemIsFocused = component.model.kind == .carousel || itemIndex < Int(component.model.layout.span)
    let hasReachedTop = isFirstComponent && firstRowItemIsFocused
    let windowHeight = component.view.window?.frame.size.height ?? 0.0
    let componentWindowDiff = windowHeight - component.view.frame.size.height
    let insets = CGFloat(component.model.layout.inset.top + component.model.layout.inset.bottom)
    let hasReachedEnd = scrollView.contentSize.height - scrollView.frame.size.height - componentWindowDiff + insets

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
    } else if component.model.kind == .grid && direction == .down {
      var result: CGFloat = 0
      if let cell: UIView = component.userInterface!.cell(at: itemIndex) {
        if let spotsScrollView = scrollView as? SpotsScrollView,
          let yPosition = spotsScrollView.sizeCache[component.model.index] {
          result = yPosition + cell.frame.origin.y - contentInsetTop
          result -= CGFloat(component.model.layout.lineSpacing + component.model.layout.inset.top + component.model.layout.inset.bottom)
        }
      }

      if result >= hasReachedEnd {
        result = hasReachedEnd + componentWindowDiff
        return
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

