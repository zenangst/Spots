import UIKit

/// SpotsContentView is a container view that lives on `SpotsScrollView`.
/// All views that gets added to the view hierarchy using a `SpotsController`
/// reside in `SpotsContentView`, in that scenario it is the parent of all `Component` views.
/// When a view is added, it will invoke `didAddSubviewToContainer` on `SpotsScrollView` to
/// start monitoring the view using KVO. When a view will be removed `willRemoveSubview` is
/// invoked on `SpotsScrollView` to remove any KVO setup for the view on question.
/// When a `Component` performs any mutating operation, it will end up calling `afterUpdate`
/// which calls `layoutSubviews` on its parent. The parent being `SpotsContentView`. That
/// method then relays the invocation to call `layoutViews` on `SpotsScrollView. This will
/// cause the `SpotsScrollView` layout operation to be called, causing the layout to be
/// invalidated and re-rendered.
open class SpotsContentView: UIView {

  /// Tells the view that a subview was added.
  ///
  /// - parameter subview: The view that was added as a subview.
  override open func didAddSubview(_ subview: UIView) {
    super.didAddSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else {
      return
    }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /// Tells the view that a subview is about to be removed.
  ///
  /// - parameter subview: Tells the view that a subview is about to be removed.
  override open func willRemoveSubview(_ subview: UIView) {
    super.willRemoveSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else {
      return
    }
    containerScrollView.willRemoveSubview(subview)
  }

  /// The default implementation of this method does nothing on iOS 5.1 and earlier. 
  /// Otherwise, the default implementation uses any constraints you have set to 
  /// determine the size and position of any subviews.
  /// If `SpotsContentView` is added to a `SpotsScrollView` it will invoke `layoutViews`
  /// to trigger a re-rendering of all components.
  open override func layoutSubviews() {
    super.layoutSubviews()

    guard let containerScrollView = superview as? SpotsScrollView else {
      return
    }

    containerScrollView.layoutViews()
  }
}
