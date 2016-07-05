import Cocoa

class Toolbar: NSToolbar {

  override init(identifier: String) {
    super.init(identifier: identifier)

    self.delegate = self
    allowsUserCustomization = false
    showsBaselineSeparator = false
  }
}

extension Toolbar: NSToolbarDelegate {

  func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String] {
    return [
      "back",
      "forward",
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
    case "back":
      let backButton = NavigationToolbarItem(itemIdentifier: "back", imageString: "leftArrow", action: "back")
      toolbarItem = backButton
    case "forward":
      let forwardButton = NavigationToolbarItem(itemIdentifier: "forward", imageString: "rightArrow", action: "forward")
      toolbarItem = forwardButton
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
      "back",
      "forward",
      "title",
      "search",
      NSToolbarSpaceItemIdentifier,
      NSToolbarFlexibleSpaceItemIdentifier
    ]
  }
}
