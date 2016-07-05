import Cocoa

public class NoScrollView: NSScrollView {

  var scrollingEnabled: Bool = true

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    drawsBackground = false
    hasHorizontalScroller = false
    hasVerticalScroller = false
    scrollsDynamically = true
    automaticallyAdjustsContentInsets = false
    scrollerStyle = .Overlay
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func scrollWheel(theEvent: NSEvent) {
    if theEvent.scrollingDeltaX != 0.0 && horizontalScroller != nil && scrollingEnabled {
      super.scrollWheel(theEvent)
    } else {
      nextResponder?.scrollWheel(theEvent)
    }
  }

  static public override func isCompatibleWithResponsiveScrolling() -> Bool {
    return true
  }

  override public var allowsVibrancy: Bool {
    return true
  }
}
