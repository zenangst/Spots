import Cocoa
import Sugar

public class TitleToolbarItem: NSToolbarItem {

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.font = NSFont.systemFontOfSize(14)
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
//    $0.cell?.backgroundStyle = .Raised
    $0.wantsLayer = true
  }

  lazy public var customView = NSView().then {
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
