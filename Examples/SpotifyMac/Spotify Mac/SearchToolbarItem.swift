import Cocoa

public class SearchToolbarItem: NSToolbarItem {

  public lazy var titleLabel = NSTextField().then {
    $0.editable = true
    $0.selectable = true
    $0.bezeled = true
    $0.bezelStyle = .RoundedBezel
    $0.cell?.backgroundStyle = .Raised
    $0.wantsLayer = true

  }

  lazy public var customView = NSView().then {
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
