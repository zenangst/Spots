import Cocoa

class MainSplitView : NSSplitView {

  let startWidth: CGFloat = 250
  let minimumWidth: CGFloat = 200
  let maximumWidth: CGFloat = 300

  var listView: NSView!
  var detailView: NSView! {
    didSet {
      subviews.removeLast()
      addSubview(detailView)
      adjustSubviews()
      setPosition(startWidth, ofDividerAtIndex: 0)
    }
  }

  override var dividerColor: NSColor {
    return NSColor(red:0.2, green:0.2, blue:0.2, alpha: 1)
  }

  override init(frame: NSRect) {
    super.init(frame: frame)

    delegate = self
    dividerStyle = .Thin
    autosaveName = "MainSplitView"
    vertical = true
    autoresizingMask = .ViewNotSizable
    autoresizesSubviews = false
  }

  init(listView: NSView, detailView: NSView) {
    self.init()

    self.listView = listView
    self.detailView = detailView

    addSubview(listView)
    addSubview(detailView)
  }

  override func viewDidMoveToWindow() {
    setPosition(startWidth, ofDividerAtIndex: 0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension MainSplitView: NSSplitViewDelegate {

  func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    return dividerIndex == 0 ? maximumWidth : proposedMaximumPosition
  }

  func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    return dividerIndex == 0 ? minimumWidth : proposedMinimumPosition
  }

  func splitViewWillResizeSubviews(notification: NSNotification) {
    if listView.frame.width >= maximumWidth {
      listView.frame.size.width = maximumWidth
    } else if listView.frame.width <= minimumWidth {
      listView.frame.size.width = minimumWidth
    }
  }

  func splitViewDidResizeSubviews(notification: NSNotification) {
    subviews.forEach { $0.layout() }
  }

  func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
    return false
  }
}
