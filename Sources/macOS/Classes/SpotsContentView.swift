import Cocoa

open class SpotsContentView: NSView {

  override open var isFlipped: Bool {
    return true
  }

  func insertSubview(_ view: View, at index: Int) {
    subviews.insert(view, at: index)
  }

  /**
   Tells the view that a subview was added.

   - parameter subview: The view that was added as a subview.
   */
  override open func didAddSubview(_ subview: View) {
    super.didAddSubview(subview)

    guard let clipView = superview,
      let containerScrollView = clipView.superview as? SpotsScrollView else {
        return
    }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: Tells the view that a subview is about to be removed.
   */
  override open func willRemoveSubview(_ subview: View) {
    super.willRemoveSubview(subview)

    guard let clipView = superview,
      let containerScrollView = clipView.superview as? SpotsScrollView else {
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

    guard let clipView = superview,
      let containerScrollView = clipView.superview as? SpotsScrollView else {
        return
    }

    containerScrollView.layoutViews()
  }
}
