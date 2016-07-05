import Cocoa

class Window: NSWindow, NSWindowDelegate {

  lazy var customToolbar = Toolbar(identifier: "main-toolbar")

  override var canBecomeMainWindow: Bool {
    get { return true }
  }

  override var canBecomeKeyWindow: Bool {
    get { return true }
  }

  override var contentView: NSView? {
    didSet {
      guard let contentView = contentView else { return }

      let gradientLayer = CAGradientLayer()
      gradientLayer.colors = [
        NSColor(red:0.15, green:0.15, blue:0.15, alpha: 1).CGColor,
        NSColor(red:0.1, green:0.1, blue:0.1, alpha: 1).CGColor,
      ]
      gradientLayer.locations = [0.0, 0.4]
      gradientLayer.frame.size = contentView.frame.size

      contentView.wantsLayer = true
      contentView.layer = gradientLayer
    }
  }

  override init (contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
    super.init (contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)

    self.titleVisibility = .Hidden
    self.styleMask =
      NSClosableWindowMask |
      NSMiniaturizableWindowMask |
      NSResizableWindowMask |
      NSBorderlessWindowMask |
      NSTitledWindowMask |
      NSTexturedBackgroundWindowMask
    self.opaque = false
    self.titlebarAppearsTransparent = true
    self.toolbar = customToolbar
    self.minSize = NSSize(width: 960, height: 640)
    self.movable = true
    self.delegate = self
    self.backgroundColor = NSColor(red:0.2, green:0.2, blue:0.2, alpha: 1)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension Window {

  func windowDidExitFullScreen(notification: NSNotification) {
    toolbar = customToolbar
  }

  func windowWillEnterFullScreen(notification: NSNotification) {
    toolbar = nil
  }
}
