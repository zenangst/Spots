import Cocoa

class WindowBackgroundView: NSView {

  var backgroundColor: NSColor?

  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)

    if let backgroundColor = backgroundColor {
      backgroundColor.setFill()
      NSRectFill(dirtyRect)
    }
  }

}
