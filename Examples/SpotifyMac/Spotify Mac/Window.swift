import Cocoa

class Window: NSWindow {

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
        NSColor(red:0.165, green:0.169, blue:0.169, alpha: 1).CGColor,
        NSColor.blackColor().CGColor
      ]
      gradientLayer.locations = [0.0, 1.0]
      gradientLayer.frame.size = contentView.frame.size

      contentView.wantsLayer = true
      contentView.layer = gradientLayer
    }
  }

  override init (contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
    super.init (contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)

    self.titleVisibility = NSWindowTitleVisibility.Hidden
    self.toolbar = toolbar
    self.styleMask =
      NSClosableWindowMask |
      NSMiniaturizableWindowMask |
      NSResizableWindowMask |
      NSBorderlessWindowMask |
      NSTitledWindowMask
    self.opaque = false
    self.titlebarAppearsTransparent = true
    self.backgroundColor = NSColor(red:0.165, green:0.169, blue:0.169, alpha: 1)
    self.movable = true
    self.movableByWindowBackground = true

    if let contentView = contentView, layer = contentView.layer as? CAGradientLayer,
    colors = layer.colors as? [CGColorRef], firstColor = colors.first {
      self.backgroundColor = NSColor(CGColor: firstColor)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
