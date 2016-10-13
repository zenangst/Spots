import Cocoa

open class SearchToolbarItem: NSToolbarItem {

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = true
    $0.isSelectable = true
    $0.isBezeled = true
    $0.bezelStyle = .roundedBezel
    $0.cell?.backgroundStyle = .raised
    $0.wantsLayer = true
  }

  lazy open var customView = NSView().then {
    $0.wantsLayer = true
    $0.layer = CALayer()
  }

  init(itemIdentifier: String, text: String) {
    super.init(itemIdentifier: itemIdentifier)

    label = text
    titleLabel.placeholderString = text
    titleLabel.sizeToFit()
    titleLabel.frame.size.width = 200
    titleLabel.frame.size.height = 22
    customView.frame = titleLabel.frame
    customView.addSubview(titleLabel)
    view = customView
  }
}
