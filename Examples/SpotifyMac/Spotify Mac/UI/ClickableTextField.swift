import Cocoa

public class ClickableTextField: NSTextField {

  var clickAction: Selector?
  var clickType: ClickType = .Single

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let area = NSTrackingArea(rect: self.bounds, options: [.InVisibleRect, .MouseEnteredAndExited, .ActiveInKeyWindow], owner: self, userInfo: nil)
    addTrackingArea(area)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func mouseDown(theEvent: NSEvent) {
    if let clickAction = clickAction where theEvent.clickCount == clickType.rawValue && theEvent.type == .LeftMouseDown {
      let point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
      if NSPointInRect(point, self.bounds) {
        NSApp.sendAction(clickAction, to: target, from: self)
      } else {
        super.mouseDown(theEvent)
      }
    }
  }

  public override func mouseEntered(theEvent: NSEvent) {
    super.mouseEntered(theEvent)
    
    guard let _ = clickAction else { return }

    let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
    attributedString.addAttributes([NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue], range: NSRange(location: 0, length: attributedString.length))
    attributedStringValue = attributedString
  }

  public override func mouseExited(theEvent: NSEvent) {
    super.mouseExited(theEvent)
    
    guard let _ = clickAction else { return }

    let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
    attributedString.addAttributes([NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue], range: NSRange(location: 0, length: attributedString.length))
    attributedStringValue = attributedString
  }
}
