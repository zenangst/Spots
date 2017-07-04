import Cocoa

open class SpotsScrollView: NSScrollView {

  /// When enabled, the last `Component` in the collection will be stretched to occupy the remaining space.
  /// This can be enabled globally by setting `Configuration.stretchLastComponent` to `true`.
  ///
  /// ```
  ///  Enabled    Disabled
  ///  --------   --------
  /// ||¯¯¯¯¯¯|| ||¯¯¯¯¯¯||
  /// ||      || ||      ||
  /// ||______|| ||______||
  /// ||¯¯¯¯¯¯|| ||¯¯¯¯¯¯||
  /// ||      || ||      ||
  /// ||      || ||______||
  /// ||______|| |        |
  ///  --------   --------
  /// ```
  public var stretchLastComponent = Configuration.stretchLastComponent

  /// A KVO context used to monitor changes in contentSize, frames and bounds
  let subviewContext: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(mutating: nil)

  /// Toggles if animations should be enabled or not.
  public var isAnimationsEnabled: Bool = false
  public var inset: Inset?

  /// A collection of NSView's that resemble the order of the views in the scroll view.
  fileprivate var observedViews = [NSView]()

  open var forceUpdate = false {
    didSet {
      if forceUpdate {
        layoutSubtreeIfNeeded()
      }
    }
  }

  /// The document view of SpotsScrollView.
  lazy open var componentsView: SpotsContentView = {
    let contentView = SpotsContentView()
    contentView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    contentView.autoresizesSubviews = true

    return contentView
  }()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.documentView = componentsView
    drawsBackground = false
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Cleanup observers.
  deinit {
    for subview in observedViews {
      unobserveView(subview)
    }
  }

  /// Allows keyed coding.
  ///
  /// - Returns: Always returns true.
  func allowsKeyedCoding() -> Bool {
    return true
  }

  private func observeView(_ view: NSView) {
    guard observedViews.contains(where: { $0 == view }) else {
      return
    }

    view.addObserver(self, forKeyPath: #keyPath(frame), options: .old, context: subviewContext)
    observedViews.append(view)
  }

  private func unobserveView(_ view: NSView) {
    guard let index = observedViews.index(where: { $0 == view }) else {
      return
    }

    view.removeObserver(self, forKeyPath: #keyPath(frame), context: subviewContext)
    observedViews.remove(at: index)
  }

  /// A subview was added to the container.
  ///
  /// - Parameter subview: The subview that was added.
  func didAddSubviewToContainer(_ subview: View) {
    guard componentsView.subviews.index(of: subview) != nil else {
      return
    }

    for subview in componentsView.subviews {
      observeView(subview)
    }
    layoutViews(animated: true)
  }

  /// Will remove subview from container.
  ///
  /// - Parameter subview: The subview that will be removed.
  open override func willRemoveSubview(_ subview: View) {
    unobserveView(subview)
    layoutViews(animated: true)
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let change = change, let view = object as? View, context == subviewContext {
      if let value = change[NSKeyValueChangeKey.oldKey] as? NSValue, keyPath == #keyPath(frame) {
        if value.rectValue != view.frame {
          layoutSubtreeIfNeeded()
        }
      }
    }
  }

  open func isCompatibleWithResponsiveScrolling() -> Bool {
    return true
  }

  open override func viewDidMoveToWindow() {
    layoutSubtreeIfNeeded()
  }

  /// Layout all subviews in the collection ordered by `subviewsInLayoutOrder` on `SpotsContentView`.
  ///
  /// - Parameter animated: Determines if animations should be used when updating the frames of the
  ///                       underlaying views.
  func layoutViews(animated: Bool = true) {
    var yOffsetOfCurrentSubview: CGFloat = CGFloat(self.inset?.top ?? 0.0)
    let lastView = componentsView.subviewsInLayoutOrder.last

    for subview in componentsView.subviewsInLayoutOrder {
      if let scrollView = subview as? ScrollView {
        var contentOffset = scrollView.contentOffset
        var frame = scrollView.frame
        if self.contentOffset.y <= yOffsetOfCurrentSubview {
          contentOffset.y = 0.0
          frame.origin.y = yOffsetOfCurrentSubview
        }

        frame.size.width = ceil(contentView.frame.size.width)

        if let inset = self.inset {
          frame.size.width -= CGFloat(inset.left + inset.right)
          frame.origin.x = CGFloat(inset.left)
        }

        if stretchLastComponent && scrollView.isEqual(lastView) {
          let newHeight = self.frame.size.height - scrollView.frame.origin.y + self.contentOffset.y

          if newHeight >= frame.size.height {
            frame.size.height = newHeight
          }
        }

        let shouldAnimate = isAnimationsEnabled && window?.inLiveResize == false && animated
        if shouldAnimate {
          scrollView.animator().frame = frame
        } else {
          scrollView.frame = frame
        }

        scrollView.contentOffset = contentOffset

        yOffsetOfCurrentSubview += scrollView.frame.height
      } else {
        var frame = subview.frame
        if self.contentOffset.y <= yOffsetOfCurrentSubview {
          frame.origin.y = yOffsetOfCurrentSubview
        }

        frame.origin.x = 0.0

        if let inset = self.inset {
          frame.size.width -= CGFloat(inset.left + inset.right)
          frame.origin.x -= CGFloat(inset.left)
        }

        subview.frame = frame
        yOffsetOfCurrentSubview += subview.frame.height
      }
    }

    yOffsetOfCurrentSubview -= CGFloat(self.inset?.bottom ?? 0.0)

    guard frame.height > 0 && frame.width > 100 else {
      return
    }

    if frame.origin.y < 0 {
      yOffsetOfCurrentSubview -= frame.origin.y
    }

    let frameComparison: CGFloat = frame.height - contentInsets.top - CGFloat(self.inset?.bottom ?? 0.0)

    documentView?.setFrameSize(CGSize(width: frame.width, height: fmax(yOffsetOfCurrentSubview, frameComparison)))

    if let view = superview {
      view.layout()
    }
  }

  open override func layoutSubtreeIfNeeded() {
    super.layoutSubtreeIfNeeded()

    layoutViews(animated: false)
  }
}
