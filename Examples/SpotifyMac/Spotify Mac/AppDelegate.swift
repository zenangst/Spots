import Cocoa
import Spots
import Sugar
import Compass

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: Window!

  var toolbar = Toolbar(identifier: "main-toolbar")
  var menuController = MenuController(cacheKey: "menu-cache")
  var featuredController = FeaturedController(cacheKey: "main-screen-cache")

  let configurators: [Configurator] = [
    SpotsConfigurator(),
    CompassConfigurator(),
  ]

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    configurators.forEach { $0.configure() }

    delay(0.3) {
      (self.menuController.spot as? Gridable)?.collectionView.selectItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], scrollPosition: .None)
    }
    let splitView = MainSplitView(listView: menuController.view,
                                  detailView: featuredController.view)

    registerURLScheme()

    window.toolbar = toolbar
    window.contentView = splitView
    window.becomeKeyWindow()
  }

  }
}
