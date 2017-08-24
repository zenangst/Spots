import Cocoa

class ComponentClipView: NSClipView {
  /// This method is used to avoid recursion when `SpotsScrollView`
  /// scrolls the underlaying view.
  ///
  /// - Parameter point: The new origin.
  func scrollWithSuperView(_ point: CGPoint) {
    super.scroll(to: point)
  }

  /// This method is overriden to rely the scrolling to `SpotsScrollView`
  /// when the `Component` is used inside a `SpotsController.
  ///
  /// - Parameter newOrigin: The new origin.
  override func scroll(to newOrigin: NSPoint) {
    if let collectionView = documentView as? CollectionView {
      if (collectionView.collectionViewLayout as? FlowLayout)?.scrollDirection == .horizontal {

        super.scroll(to: newOrigin)
        return
      }
    }

    guard let scrollView = superview?.enclosingScrollView as? SpotsScrollView else {
      super.scroll(newOrigin)
      return
    }

    scrollView.documentView?.scroll(newOrigin)
  }
}

/// A custom implementation of `NSScrollView` used inside `Component`
/// It hides the vertical scroll indicator and uses a custom `NSClipView`
/// to properly forward events to its enclosing scroll view so when using
/// multiple components inside of a controller you get a unified and smooth
/// scrolling experience.
open class ComponentScrollView: NSScrollView {
  /// Determines if scrolling is enabled or not.
  var scrollingEnabled: Bool = true
  override open var allowsVibrancy: Bool { return true }
  /// Override the setter and getter for the vertical scroller to remove it permanently.
  open override var verticalScroller: NSScroller? {
    get { return nil }
    set {}
  }

  /// Initializes and returns a newly allocated NSView object with a specified frame rectangle.
  ///
  /// - Parameter frameRect: The frame rectangle for the created view object.
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    drawsBackground = false
    hasVerticalScroller = false
    scrollsDynamically = true
    automaticallyAdjustsContentInsets = false
    scrollerStyle = .overlay
    contentView = ComponentClipView()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// If a user scrolls vertically, the even should be forwarded to the
  /// enclosing scroll view. See the class documentation for more information
  /// about the desired behavior.
  ///
  /// - Parameter theEvent: The scroll wheel event that the view recieved.
  override open func scrollWheel(with theEvent: NSEvent) {
    if theEvent.scrollingDeltaX != 0.0 && scrollingEnabled {
      super.scrollWheel(with: theEvent)
    } else if theEvent.scrollingDeltaY != 0.0 {
      nextResponder?.scrollWheel(with: theEvent)
    }
  }
}
