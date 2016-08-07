import Cocoa

enum ClickType: Int {
  case Single = 1
  case Double = 2
}

class ClickableImageView: NSImageView {

  var clickAction: Selector?
  var clickType: ClickType = .Single

  override func mouseDown(theEvent: NSEvent) {
    if let clickAction = clickAction where theEvent.clickCount == clickType.rawValue && theEvent.type == .LeftMouseDown {
      let point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
      if NSPointInRect(point, self.bounds) {
        NSApp.sendAction(clickAction, to: target, from: self)
      } else {
        super.mouseDown(theEvent)
      }
    }
  }
}
