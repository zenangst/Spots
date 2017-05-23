import UIKit

/// A container view for KVO inside SpotsScrollView
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
