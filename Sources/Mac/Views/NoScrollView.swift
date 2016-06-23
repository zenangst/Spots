import Cocoa

public class NoScrollView: NSScrollView {

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    drawsBackground = false
    hasHorizontalScroller = false
    hasVerticalScroller = false
    scrollsDynamically = true
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func scrollWheel(theEvent: NSEvent) {
    if theEvent.scrollingDeltaX != 0.0 && horizontalScroller != nil {
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
