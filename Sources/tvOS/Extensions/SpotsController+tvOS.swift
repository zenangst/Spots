import UIKit

// An extension for SpotsController to make it easier to configure and access `UIFocusGuide`.
extension SpotsController {
  // A convenience method for resolving the focus guides preferred focused view
  public var focusGuidePreferredView: UIView? {
    set {
      if #available(tvOS 10.0, *) {
        focusGuide.preferredFocusEnvironments = [view]
      } else {
        focusGuide.preferredFocusedView = view
      }
    }
    get {
      if #available(tvOS 10.0, *) {
        return focusGuide.preferredFocusEnvironments.first as? UIView
      } else {
        return focusGuide.preferredFocusedView
      }
    }
  }

  /// Add and constrain the focus guide to a given view.
  /// The default view in `viewDidLoad` of the `SpotsController` is
  /// the controllers scrollview.
  ///
  /// - Parameters:
  ///   - focusGuide: The focus guide that should be added to the view.
  ///   - view: The view that should own the focus guide.
  ///   - enabled: Determines if the focus guide should be enabled or not, it defaults to `false`.
  func configure(focusGuide: UIFocusGuide, for view: UIView, enabled: Bool = false) {
    focusGuide.isEnabled = enabled
    view.addLayoutGuide(focusGuide)
    focusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    focusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    focusGuide.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    focusGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }

  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let focusedComponent = focusedComponent else {
      return
    }

    if focusedComponent == components.first {
      if #available(tvOS 11.0, *) {
        targetContentOffset.pointee.y = -scrollView.adjustedContentInset.top
      } else {
        targetContentOffset.pointee.y = -scrollView.contentInset.top
      }
      return
    }

    guard focusedComponent != components.last else {
      targetContentOffset.pointee.y = scrollView.contentSize.height - scrollView.frame.size.height
      return
    }

    let directionUp = velocity.y < 0
    let directionDown = velocity.y > 0
    let itemSize = focusedComponent.item(at: 0)?.size ?? focusedComponent.view.contentSize
    var layoutOffset = CGFloat(focusedComponent.model.layout.inset.top + focusedComponent.model.layout.inset.bottom)
    layoutOffset += focusedComponent.headerHeight
    layoutOffset += focusedComponent.footerHeight

    var offset: CGFloat = 0.0
    if scrollView.contentInset.top > 0, components.count > 3, focusedComponent === components[1] {
      offset = scrollView.contentInset.top - layoutOffset
      if #available(tvOS 11.0, *) {
        offset = scrollView.frame.size.height - scrollView.adjustedContentInset.top - layoutOffset
      } else {
        offset = scrollView.frame.size.height - scrollView.contentInset.top - layoutOffset
      }
    }

    guard scrollView.contentOffset != targetContentOffset.pointee else {
      return
    }

    if directionUp {
      targetContentOffset.pointee.y = scrollView.contentOffset.y - itemSize.height - layoutOffset
    } else if directionDown {
      targetContentOffset.pointee.y = scrollView.contentOffset.y + itemSize.height + offset + layoutOffset
    } else {
      targetContentOffset.pointee.y = scrollView.contentOffset.y
    }

    components.forEach { component in
      component.view.layoutSubviews()
    }
  }
}
