import UIKit

/// A container view for KVO inside SpotsScrollView
public class SpotsContentView: UIView {

  /**
   Tells the view that a subview was added.

   - parameter subview: The view that was added as a subview.
   */
  override public func didAddSubview(subview: UIView) {
    super.didAddSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: Tells the view that a subview is about to be removed.
   */
  override public func willRemoveSubview(subview: UIView) {
    super.willRemoveSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.willRemoveSubview(subview)
  }
}
