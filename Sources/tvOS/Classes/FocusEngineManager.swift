import UIKit

class FocusEngineManager {
  var lastFocusedComponent: Component?
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

  func handleScrolling(in scrollView: ScrollView, for component: Component, itemIndex: Int, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    defer {
      lastFocusedComponent = component
    }

    switch component.model.kind {
    case .carousel:
      handleHorizontalComponent(in: scrollView, for: component, itemIndex: itemIndex, withVelocity: velocity, targetContentOffset: targetContentOffset)
    case .grid:
      handleVerticalComponent(in: scrollView, for: component, itemIndex: itemIndex, withVelocity: velocity, targetContentOffset: targetContentOffset)
    default:
      break
    }
  }

  private func handleHorizontalComponent(in scrollView: ScrollView, for component: Component, itemIndex: Int, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let frameCache = (component.collectionView?.collectionViewLayout as? ComponentFlowLayout)?.cachedFrames
    let itemSize = component.item(at: itemIndex)!.size
    var itemOffset = itemSize.height

    if let frameCache = frameCache, itemIndex < frameCache.count {
      itemOffset = frameCache[itemIndex].maxY
    }

    // Don't invoke this behavior if the pointee is the same as the scroll views content offset.
    guard scrollView.contentOffset != targetContentOffset.pointee else {
      Swift.print("opt-out")
      return
    }

    // Reached the end of the screen.
    let maximumContentOffset = scrollView.contentSize.height - scrollView.frame.size.height
    if targetContentOffset.pointee.y >= maximumContentOffset {
      targetContentOffset.pointee.y = maximumContentOffset
      Swift.print("end of screen")
      return
    }

    let initialContentOffset: CGFloat
    if #available(tvOS 11.0, *) {
      initialContentOffset = scrollView.adjustedContentInset.top
    } else {
      initialContentOffset = scrollView.contentInset.top
    }

    // Reached the top
    if component.model.index == 0 {
      if component.model.kind == .carousel {
        targetContentOffset.pointee.y = -initialContentOffset
        Swift.print("reached top: \(#function)")
        return
      } else if component.model.kind == .grid && itemIndex < Int(component.model.layout.span) {
        targetContentOffset.pointee.y = -initialContentOffset
        Swift.print("reached top: \(#function)")
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
      Swift.print("opt-out \(#function)")
      targetContentOffset.pointee.y = scrollView.contentOffset.y
      return
    }

    switch direction {
    case .up:
      targetContentOffset.pointee.y = scrollView.contentOffset.y - itemOffset - layoutOffset
      Swift.print("up")
    case .down:
      targetContentOffset.pointee.y = scrollView.contentOffset.y + itemOffset + layoutOffset
      Swift.print("down")
    case .noscroll:
      targetContentOffset.pointee.y = scrollView.contentOffset.y
      Swift.print("noscroll")
    }

    lastOffset = itemOffset
  }

  private func handleVerticalComponent(in scrollView: ScrollView, for component: Component, itemIndex: Int, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let direction = Direction.determine(lhs: scrollView.contentOffset,
                                        rhs: targetContentOffset.pointee)

    let initialContentInset: CGFloat
    if #available(tvOS 11.0, *) {
      initialContentInset = scrollView.adjustedContentInset.top
    } else {
      initialContentInset = scrollView.contentInset.top
    }

    if direction == .up {
      let itemHeight = component.sizeForItem(at: IndexPath(row: itemIndex, section: 0)).height
      let headerHeight = component.headerHeight
      let lineHeight = CGFloat(component.model.layout.lineSpacing)
      let combined = itemHeight + headerHeight + lineHeight
      var result = scrollView.contentOffset.y - combined

      if let cell: UIView = component.userInterface!.cell(at: itemIndex) {
        if let spotsScrollView = scrollView as? SpotsScrollView,
          let yPosition = spotsScrollView.sizeCache[component.model.index] {
          let result = yPosition + cell.frame.origin.y - initialContentInset
        }
      }

      // Reached the top
      if component.model.index == 0 {
        if component.model.kind == .grid && itemIndex < Int(component.model.layout.span) {
          targetContentOffset.pointee.y = -initialContentInset
          Swift.print("reached top: \(#function)")
          return
        }
      }

      targetContentOffset.pointee.y = result
    }
  }
}
