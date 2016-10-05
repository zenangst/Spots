import Cocoa

public extension NSImage {

  var tintColor: NSColor? {
    get {
      return nil
    }
    set {
      guard let tintColor = newValue else { return }

      lockFocus()
      tintColor.set()

      let imageRect = NSRect(origin: NSZeroPoint, size: size)
      NSRectFillUsingOperation(imageRect, NSCompositingOperation.sourceAtop)
      unlockFocus()
    }
  }
}

public extension NSImageView {

  var tintColor: NSColor? {
    get {
      return nil
    }
    set {
      guard let tintColor = newValue,
        let image = image,
        let tinted = image.copy() as? NSImage else { return }

      tinted.lockFocus()
      tintColor.set()

      let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
      NSRectFillUsingOperation(imageRect, NSCompositingOperation.sourceAtop)
      tinted.unlockFocus()

      self.image = tinted
    }
  }

}
