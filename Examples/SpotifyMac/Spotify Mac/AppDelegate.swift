import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: Window!

  var toolbar: Toolbar?
  var menuController = MenuController(cacheKey: "menu-cache")

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    SpotsConfigurator.configure()
    let featuredController = FeaturedController(cacheKey: "main-screen-cache")
    let splitView = MainSplitView(leftView: menuController.view,
                                  rightView: featuredController.view)

    toolbar = Toolbar(identifier: "main-toolbar")
    window.toolbar = toolbar
    window.contentView = splitView
    window.becomeKeyWindow()
  }
}
