import Cocoa

enum ClickType: Int {
  case single = 1
  case double = 2
}

class ClickableImageView: NSImageView {

  var clickAction: Selector?
  var clickType: ClickType = .single

  override func mouseDown(with theEvent: NSEvent) {
    if let clickAction = clickAction , theEvent.clickCount == clickType.rawValue && theEvent.type == .leftMouseDown {
      let point = self.convert(theEvent.locationInWindow, from: nil)
      if NSPointInRect(point, self.bounds) {
        NSApp.sendAction(clickAction, to: target, from: self)
      } else {
        super.mouseDown(with: theEvent)
      }
    }
  }
}
