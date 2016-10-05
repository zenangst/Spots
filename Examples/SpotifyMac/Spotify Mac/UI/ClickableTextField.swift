import Cocoa

open class ClickableTextField: NSTextField {

  var clickAction: Selector?
  var clickType: ClickType = .single

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let area = NSTrackingArea(rect: self.bounds, options: [.inVisibleRect, .mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
    addTrackingArea(area)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func mouseDown(with theEvent: NSEvent) {
    if let clickAction = clickAction , theEvent.clickCount == clickType.rawValue && theEvent.type == .leftMouseDown {
      let point = self.convert(theEvent.locationInWindow, from: nil)
      if NSPointInRect(point, self.bounds) {
        NSApp.sendAction(clickAction, to: target, from: self)
      } else {
        super.mouseDown(with: theEvent)
      }
    }
  }

  open override func mouseEntered(with theEvent: NSEvent) {
    super.mouseEntered(with: theEvent)
    
    guard let _ = clickAction else { return }

    let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
    attributedString.addAttributes([NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue], range: NSRange(location: 0, length: attributedString.length))
    attributedStringValue = attributedString
  }

  open override func mouseExited(with theEvent: NSEvent) {
    super.mouseExited(with: theEvent)
    
    guard let _ = clickAction else { return }

    let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
    attributedString.addAttributes([NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue], range: NSRange(location: 0, length: attributedString.length))
    attributedStringValue = attributedString
  }
}
