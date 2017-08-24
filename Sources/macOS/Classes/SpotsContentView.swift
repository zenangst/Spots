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
    resolveSpotsScrollView { scrollView in
      scrollView.layoutViews(animated: true)
    }
  }

  /**
   Tells the view that a subview was added.

   - parameter subview: The view that was added as a subview.
   */
  override open func didAddSubview(_ subview: View) {
    super.didAddSubview(subview)
    rebuildSubviewsInLayoutOrder()
    resolveSpotsScrollView { scrollView in
      scrollView.didAddSubviewToContainer(subview)
    }
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: Tells the view that a subview is about to be removed.
   */
  override open func willRemoveSubview(_ subview: View) {
    super.willRemoveSubview(subview)
    rebuildSubviewsInLayoutOrder(exceptSubview: subview)
    resolveSpotsScrollView { scrollView in
      scrollView.willRemoveSubview(subview)
    }
  }

  /// The default implementation of this method does nothing on iOS 5.1 and earlier.
  /// Otherwise, the default implementation uses any constraints you have set to
  /// determine the size and position of any subviews.
  /// If `SpotsContentView` is added to a `SpotsScrollView` it will invoke `layoutViews`
  /// to trigger a re-rendering of all components.
  open override func layoutSubviews() {
    super.layoutSubviews()
    resolveSpotsScrollView { scrollView in
      scrollView.layoutViews(animated: false)
    }
  }

  /// Scrolls the view’s closest ancestor NSClipView object so a point in the view lies at the origin of the clip view's bounds rectangle.
  /// When invoked, the parent view (namely `SpotsScrollView`) will recieve instructions to layout its underlaying views.
  ///
  /// - Parameter point: The point in the view to scroll to.
  open override func scroll(_ point: NSPoint) {
    super.scroll(point)

    resolveSpotsScrollView { spotsScrollView in
      spotsScrollView.layoutViews(animated: false)
    }
  }

  /// Resolve `SpotsScrollView` based of the `SpotsContentView`'s superview.
  ///
  /// - Parameter closure: A closure that returns the resolved `SpotsScrollView`.
  ///                      Note: The closure will not execute if the `SpotsScrollView` cannot
  ///                      be resolved.
  private func resolveSpotsScrollView(_ closure: (SpotsScrollView) -> Void) {
    guard let clipView = superview,
      let spotsScrollView = clipView.superview as? SpotsScrollView else {
        return
    }

    closure(spotsScrollView)
  }

  /// Rebuild the `subviewsInLayoutOrder`.
  private func rebuildSubviewsInLayoutOrder(exceptSubview: View? = nil) {
    subviewsInLayoutOrder.removeAll()
    let filteredSubviews = subviews.filter({ !($0 === exceptSubview) })
    subviewsInLayoutOrder = filteredSubviews
  }
}
