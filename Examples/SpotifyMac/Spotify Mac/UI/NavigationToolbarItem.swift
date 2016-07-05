import Cocoa

public class NavigationToolbarItem: NSToolbarItem {

  lazy public var customView = NSView().then {
    $0.wantsLayer = true
    $0.layer = CALayer()
  }

  lazy public var button = NSButton().then {
    $0.transparent = false
    $0.bordered = false
  }

  init(itemIdentifier: String, imageString: String, action: String) {
    super.init(itemIdentifier: itemIdentifier)

    label = action
    target = self
    self.action = #selector(NavigationToolbarItem.navigate(_:))
    enabled = true
    view = customView
    customView.addSubview(button)
    button.title = ""
    let image = NSImage(named: imageString)
    image?.tintColor = NSColor.whiteColor()
    image?.size = CGSize(width: 8, height: 14)
    button.image = image

    button.sizeToFit()
    button.target = self
    button.action = #selector(NavigationToolbarItem.navigate(_:))
    customView.frame.size = CGSize(width: 16, height: 14)
    maxSize = customView.frame.size
    minSize = customView.frame.size
  }

  func navigate(sender: NavigationToolbarItem) {
    AppDelegate.navigate(label)
  }
}
