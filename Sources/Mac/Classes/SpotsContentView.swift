import Cocoa

open class SpotsContentView: NSView {

  override open var isFlipped: Bool {
    get {
      return true
    }
  }

  /**
   Tells the view that a subview was added.

   - parameter subview: The view that was added as a subview.
   */
  override open func didAddSubview(_ subview: View) {
    super.didAddSubview(subview)

    guard let clipView = superview,
      let containerScrollView = clipView.superview as? SpotsScrollView else { return }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: Tells the view that a subview is about to be removed.
   */
  override open func willRemoveSubview(_ subview: View) {
    super.willRemoveSubview(subview)

    guard let clipView = superview,
      let containerScrollView = clipView.superview as? SpotsScrollView else { return }
    containerScrollView.willRemoveSubview(subview)
  }
}
