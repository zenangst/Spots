import Cocoa
import Sugar

open class TitleToolbarItem: NSToolbarItem {

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.font = NSFont.systemFont(ofSize: 14)
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.wantsLayer = true
  }

  lazy open var customView = NSView().then {
    $0.wantsLayer = true
    $0.layer = CALayer()
  }

  init(itemIdentifier: String, text: String) {
    super.init(itemIdentifier: itemIdentifier)

    label = text
    titleLabel.stringValue = text
    titleLabel.sizeToFit()
    customView.frame = titleLabel.frame
    customView.addSubview(titleLabel)
    view = customView
  }
}
