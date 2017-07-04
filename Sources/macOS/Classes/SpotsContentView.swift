import Cocoa

open class SpotsContentView: NSView {

  /// `Component` views that are ordered after the model indexes.
  var subviewsInLayoutOrder = [NSView]()

  override open var isFlipped: Bool {
    return true
  }

  /// Remove all stored subviews when the view is deallocated.
  deinit {
    subviewsInLayoutOrder.removeAll()
  }

  /// Insert view at specific index.
  ///
  /// - Parameters:
  ///   - view: The view that should be inserted.
  ///   - index: The index that the view should be inserted at.
  func insertSubview(_ view: View, at index: Int) {
    subviews.insert(view, at: index)
    rebuildSubviewsInLayoutOrder()
    spotsScrollView {
      $0.layoutViews(animated: true)
    }
  }

  /**
   Tells the view that a subview was added.

   - parameter subview: The view that was added as a subview.
   */
  override open func didAddSubview(_ subview: View) {
    super.didAddSubview(subview)
    rebuildSubviewsInLayoutOrder()
    spotsScrollView { $0.didAddSubviewToContainer(subview) }
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: Tells the view that a subview is about to be removed.
   */
  override open func willRemoveSubview(_ subview: View) {
    super.willRemoveSubview(subview)
    rebuildSubviewsInLayoutOrder()
    spotsScrollView { $0.willRemoveSubview(subview) }
  }

  /// The default implementation of this method does nothing on iOS 5.1 and earlier.
  /// Otherwise, the default implementation uses any constraints you have set to
  /// determine the size and position of any subviews.
  /// If `SpotsContentView` is added to a `SpotsScrollView` it will invoke `layoutViews`
  /// to trigger a re-rendering of all components.
  open override func layoutSubviews() {
    super.layoutSubviews()
    spotsScrollView { $0.layoutViews(animated: false) }
  }

  /// Resolve `SpotsScrollView` based of the `SpotsContentView`'s superview.
  ///
  /// - Parameter closure: A closure that returns the resolved `SpotsScrollView`.
  ///                      Note: The closure will not execute if the `SpotsScrollView` cannot
  ///                      be resolved.
  private func spotsScrollView(_ closure: (SpotsScrollView) -> Void) {
    guard let clipView = superview,
      let spotsScrollView = clipView.superview as? SpotsScrollView else {
        return
    }

    closure(spotsScrollView)
  }

  /// Rebuild the `subviewsInLayoutOrder`.
  private func rebuildSubviewsInLayoutOrder() {
    subviewsInLayoutOrder.removeAll()
    subviewsInLayoutOrder = subviews
  }
}
