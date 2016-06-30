import Cocoa

class Toolbar: NSToolbar {

  override init(identifier: String) {
    super.init(identifier: identifier)

    self.delegate = self
    allowsUserCustomization = false
    showsBaselineSeparator = true
  }
}

extension Toolbar: NSToolbarDelegate {

  func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String] {
    return [
      NSToolbarFlexibleSpaceItemIdentifier,
      "title",
      NSToolbarFlexibleSpaceItemIdentifier,
    ]
  }

  func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    var toolbarItem: NSToolbarItem? = nil
    switch itemIdentifier {
    case NSToolbarFlexibleSpaceItemIdentifier:
      toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarFlexibleSpaceItemIdentifier)
    case NSToolbarSpaceItemIdentifier:
      toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarSpaceItemIdentifier)
    case "search":
      let titleToolbar = SearchToolbarItem(itemIdentifier: "title", text: "Search...")
      toolbarItem = titleToolbar
    case "title":
      let titleToolbar = TitleToolbarItem(itemIdentifier: "title", text: "Spots for the Mac")
      toolbarItem = titleToolbar
    default:
      break
    }

    return toolbarItem
  }

  func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [String] {
    return [
      "title",
      "search",
      NSToolbarSpaceItemIdentifier,
      NSToolbarFlexibleSpaceItemIdentifier
    ]
  }

}
