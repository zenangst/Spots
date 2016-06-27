import Cocoa

public extension NSImageView {

  var tintColor: NSColor? {
    get {
      return nil
    }
    set {
      guard let tintColor = newValue,
        image = image,
        tinted = image.copy() as? NSImage else { return }

      tinted.lockFocus()
      tintColor.set()

      let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
      NSRectFillUsingOperation(imageRect, NSCompositingOperation.CompositeSourceAtop)
      tinted.unlockFocus()

      self.image = tinted
    }
  }

}
