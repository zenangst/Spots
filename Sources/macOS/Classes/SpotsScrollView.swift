import Cocoa

open class SpotsScrollView: NSScrollView {
  /// Use the flipped coordinates system so that origin.y = 0 is at the top left corner.
  override open var isFlipped: Bool { return true }

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

  /// The document view of SpotsScrollView.
  lazy open var componentsView: SpotsContentView = SpotsContentView()

  /// Initializes and returns a newly allocated NSView object with a specified frame rectangle.
  ///
  /// - Parameter frameRect: The frame rectangle for the created view object.
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.documentView = componentsView
    drawsBackground = false

    NotificationCenter.default.addObserver(self, selector: #selector(contentViewBoundsDidChange),
                                           name: NSNotification.Name.NSViewBoundsDidChange,
                                           object: contentView)
    contentView.postsBoundsChangedNotifications = true
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Cleanup observers.
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// The bounds of the scroll view clip view did change.
  func contentViewBoundsDidChange() {
    guard let window = window else {
      return
    }

    guard !window.inLiveResize else {
      return
    }
    layoutViews(animated: false)
  }

  /// A subview was added to the container.
  ///
  /// - Parameter subview: The subview that was added.
  func didAddSubviewToContainer(_ subview: View) {
    layoutViews(animated: false)
  }

  /// Will remove subview from container.
  ///
  /// - Parameter subview: The subview that will be removed.
  open override func willRemoveSubview(_ subview: View) {
    layoutViews(animated: false)
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "contentLayoutRect" {
      if #available(OSX 10.12, *) {
        // Workaround to fix the contentInset when using tabs.
        frame.size.width -= 1
        frame.size.width += 1
      }
    }
  }

  /// Layout all subviews in the collection ordered by `subviewsInLayoutOrder` on `SpotsContentView`.
  ///
  /// - Parameter animated: Determines if animations should be used when updating the frames of the
  ///                       underlaying views.
  public func layoutViews(animated: Bool = true) {
    var yOffsetOfCurrentSubview: CGFloat = CGFloat(self.inset?.top ?? 0.0)

    for case let scrollView as ScrollView in componentsView.subviewsInLayoutOrder {
      guard let documentView: View = scrollView.documentView else {
        return
      }

      var contentSize: CGSize = .zero
      var shouldResize: Bool = true

      switch documentView {
      case let collectionView as NSCollectionView:
        if let flowLayout = (collectionView.collectionViewLayout as? ComponentFlowLayout) {
          shouldResize = flowLayout.scrollDirection == .vertical
          contentSize = flowLayout.contentSize
        }
      default:
        contentSize = documentView.frame.size
      }

      var frame = scrollView.frame
      var contentOffset = scrollView.contentOffset

      if self.contentOffset.y < yOffsetOfCurrentSubview {
        contentOffset.y = 0
        frame.origin.y = yOffsetOfCurrentSubview
      } else {
        contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview
        frame.origin.y = self.contentOffset.y
      }

      let remainingBoundsHeight = fmax(self.documentView!.visibleRect.maxY - frame.minY, 0.0)
      let remainingContentHeight = fmax(contentSize.height - contentOffset.y, 0.0)
      let newHeight = fmin(remainingBoundsHeight, remainingContentHeight)
      frame.size.width = round(self.frame.size.width)
      frame.size.height = round(newHeight)

      if shouldResize {
        switch animated {
        case true:
          scrollView.animator().frame = frame
          scrollView.animator().frame.size.width = self.frame.width
          scrollView.animator().documentView?.frame.size.height = contentSize.height
        case false:
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          scrollView.frame = frame
          scrollView.documentView?.frame.size.width = self.frame.width
          scrollView.documentView?.frame.size.height = contentSize.height
          CATransaction.commit()
        }
        (scrollView.contentView as? ComponentClipView)?.scrollWithSuperView(contentOffset)
      } else {
        scrollView.frame.origin.y = yOffsetOfCurrentSubview
        scrollView.frame.size.height = contentSize.height
        scrollView.documentView?.frame.size.width = 0.0
        scrollView.documentView?.frame.size = contentSize
      }

      yOffsetOfCurrentSubview += contentSize.height
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
