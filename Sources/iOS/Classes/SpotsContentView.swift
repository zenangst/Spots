import UIKit

/// A container view for KVO inside SpotsScrollView
open class SpotsContentView: UIView {

  /// Tells the view that a subview was added.
  ///
  /// - parameter subview: The view that was added as a subview.
  override open func didAddSubview(_ subview: UIView) {
    super.didAddSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /// Tells the view that a subview is about to be removed.
  ///
  /// - parameter subview: Tells the view that a subview is about to be removed.
  override open func willRemoveSubview(_ subview: UIView) {
    super.willRemoveSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.willRemoveSubview(subview)
  }
}
