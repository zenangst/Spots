import Cocoa
import Spots

class MainWindowController: NSWindowController {

  lazy var splitViewController: NSSplitViewController = NSSplitViewController()
//  lazy var mainController: MainController = MainController()

  lazy var listItem = NSSplitViewItem(contentListWithViewController: ListController(cacheKey: "list"))
  var mainItem: NSSplitViewItem? {
    willSet {
      if let mainItem = mainItem { splitViewController.removeSplitViewItem(mainItem) }
    }
    didSet {
      guard let mainItem = mainItem else { return }
      splitViewController.addSplitViewItem(mainItem)
    }
  }

  var currentController: DetailController? {
    didSet {
      guard let currentController = currentController else {
        mainItem = nil
        return
      }
      mainItem = NSSplitViewItem(viewController: currentController)
    }
  }

  override init(window: NSWindow?) {
    super.init(window: window)

    listItem.holdingPriority = 260
    listItem.canCollapse = true

    splitViewController.addSplitViewItem(listItem)

    window?.contentViewController = splitViewController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
