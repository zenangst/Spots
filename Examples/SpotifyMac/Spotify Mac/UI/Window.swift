import Cocoa

class Window: NSWindow, NSWindowDelegate {

  lazy var customToolbar = Toolbar(identifier: "main-toolbar")

  override init (contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
    super.init (contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)

    self.titleVisibility = .hidden
    self.styleMask = [.closable, .borderless, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    self.isOpaque = false
    self.titlebarAppearsTransparent = true
    self.toolbar = customToolbar
    self.minSize = NSSize(width: 985, height: 640)
    self.isMovable = true
    self.delegate = self
    self.backgroundColor = NSColor(red:0.1, green:0.1, blue:0.1, alpha: 0.985)
  }
}

extension Window {

  func windowDidExitFullScreen(_ notification: Notification) {
    toolbar?.isVisible = true
  }

  func windowWillEnterFullScreen(_ notification: Notification) {
    toolbar?.isVisible = false
  }
}
