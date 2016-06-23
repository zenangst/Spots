import Cocoa

class MainSplitView : NSSplitView {
  
  override var dividerColor: NSColor {
    return NSColor.grayColor().colorWithAlphaComponent(0.4)
  }

  override init(frame: NSRect) {
    super.init(frame: frame)

    delegate = self
    dividerStyle = .Thin
    autosaveName = "MainSplitView"
    vertical = true
  }

  convenience init(leftView: NSView, rightView: NSView) {
    self.init()

    addSubview(leftView)
    addSubview(rightView)
  }

  override func viewDidMoveToWindow() {
    setPosition(250, ofDividerAtIndex: 0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension MainSplitView: NSSplitViewDelegate {

  func splitViewDidResizeSubviews(notification: NSNotification) {
    subviews.forEach { $0.layout() }
  }

  func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
    return false
  }
}
