import Cocoa

open class SpotsScrollView: NSScrollView {

  /// A KVO context used to monitor changes in contentSize, frames and bounds
  let subviewContext: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(mutating: nil)

  /// A collection of NSView's that resemble the order of the views in the scroll view.
  fileprivate var subviewsInLayoutOrder = [NSView]()

  open var forceUpdate = false {
    didSet {
      if forceUpdate {
        layoutSubtreeIfNeeded()
      }
    }
  }

  /// The document view of SpotsScrollView.
  lazy open var spotsContentView: SpotsContentView = {
    let contentView = SpotsContentView()
    contentView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    contentView.autoresizesSubviews = true

    return contentView
  }()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.documentView = spotsContentView
    drawsBackground = false
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Cleanup observers.
  deinit {
    subviewsInLayoutOrder.forEach {
      $0.removeObserver(self, forKeyPath: #keyPath(frame), context: subviewContext)
    }
  }

  /// Allows keyed coding.
  ///
  /// - Returns: Always returns true.
  func allowsKeyedCoding() -> Bool {
    return true
  }

  /// A subview was added to the container.
  ///
  /// - Parameter subview: The subview that was added.
  func didAddSubviewToContainer(_ subview: View) {
    subviewsInLayoutOrder.append(subview)
    subview.addObserver(self, forKeyPath: #keyPath(frame), options: .old, context: subviewContext)
    layoutSubtreeIfNeeded()
  }

  /// Will remove subview from container.
  ///
  /// - Parameter subview: The subview that will be removed.
  open override func willRemoveSubview(_ subview: View) {
    if let index = subviewsInLayoutOrder.index(where: { $0 == subview }) {
      subviewsInLayoutOrder.remove(at: index)
      layoutSubtreeIfNeeded()
      subview.removeObserver(self, forKeyPath: #keyPath(frame), context: subviewContext)
    }
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

  open override func layoutSubtreeIfNeeded() {
    super.layoutSubtreeIfNeeded()

    var yOffsetOfCurrentSubview: CGFloat = 0.0

    for subview in subviewsInLayoutOrder {
      if let scrollView = subview as? ScrollView {
        var contentOffset = scrollView.contentOffset
        var frame = scrollView.frame
        if self.contentOffset.y <= yOffsetOfCurrentSubview {
          contentOffset.y = 0.0
          frame.origin.y = yOffsetOfCurrentSubview
        }

        frame.size.width = ceil(contentView.frame.size.width)
        scrollView.frame = frame
        scrollView.contentOffset = contentOffset

        yOffsetOfCurrentSubview += scrollView.frame.height
      } else {
        var frame = subview.frame
        if self.contentOffset.y <= yOffsetOfCurrentSubview {
          frame.origin.y = yOffsetOfCurrentSubview
        }
        frame.origin.x = 0.0
        subview.frame = frame
        yOffsetOfCurrentSubview += subview.frame.height
      }
    }

    guard frame.height > 0 && frame.width > 100 else { return }

    if frame.origin.y < 0 {
      yOffsetOfCurrentSubview -= frame.origin.y
    }

    documentView?.setFrameSize(CGSize(width: frame.width, height: fmax(yOffsetOfCurrentSubview, frame.height)))
    displayIfNeeded()

    if let view = superview {
      view.layout()
    }
  }
}
