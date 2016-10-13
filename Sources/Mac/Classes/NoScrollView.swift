import Cocoa

open class NoScrollView: NSScrollView {

  var scrollingEnabled: Bool = true

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    drawsBackground = false
    hasHorizontalScroller = false
    hasVerticalScroller = false
    scrollsDynamically = true
    automaticallyAdjustsContentInsets = false
    scrollerStyle = .overlay
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func scrollWheel(with theEvent: NSEvent) {
    if theEvent.scrollingDeltaX != 0.0 && horizontalScroller != nil && scrollingEnabled {
      super.scrollWheel(with: theEvent)
    } else if theEvent.scrollingDeltaY != 0.0 {
      nextResponder?.scrollWheel(with: theEvent)
    }
  }

  static open override func isCompatibleWithResponsiveScrolling() -> Bool {
    return true
  }

  override open var allowsVibrancy: Bool {
    return true
  }
}
