import Cocoa

public class SpotsContentView: NSView {

  override public var flipped: Bool {
    get {
      return true
    }
  }

  /**
   Tells the view that a subview was added.

   - Parameter subview: The view that was added as a subview.
   */
  override public func didAddSubview(subview: RegularView) {
    super.didAddSubview(subview)

    guard let clipView = superview,
      containerScrollView = clipView.superview as? SpotsScrollView else { return }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /**
   Tells the view that a subview is about to be removed.

   - Parameter subview: Tells the view that a subview is about to be removed.
   */
  override public func willRemoveSubview(subview: RegularView) {
    super.willRemoveSubview(subview)

    guard let clipView = superview,
      containerScrollView = clipView.superview as? SpotsScrollView else { return }
    containerScrollView.willRemoveSubview(subview)
  }
}