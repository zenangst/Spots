import Cocoa

open class NavigationToolbarItem: NSToolbarItem {

  lazy open var customView = NSView().then {
    $0.wantsLayer = true
    $0.layer = CALayer()
  }

  lazy open var button = NSButton().then {
    $0.isTransparent = false
    $0.isBordered = false
  }

  init(itemIdentifier: String, imageString: String, action: String) {
    super.init(itemIdentifier: itemIdentifier)

    label = action
    target = self
    self.action = #selector(NavigationToolbarItem.navigate(_:))
    isEnabled = true
    view = customView
    customView.addSubview(button)
    button.title = ""
    let image = NSImage(named: imageString)
    image?.tintColor = NSColor.white
    image?.size = CGSize(width: 8, height: 14)
    button.image = image

    button.sizeToFit()
    button.target = self
    button.action = #selector(NavigationToolbarItem.navigate(_:))
    customView.frame.size = CGSize(width: 16, height: 14)
    maxSize = customView.frame.size
    minSize = customView.frame.size
  }

  func navigate(_ sender: NavigationToolbarItem) {
    AppDelegate.navigate(label)
  }
}
