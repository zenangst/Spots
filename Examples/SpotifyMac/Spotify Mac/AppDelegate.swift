import Cocoa
import Spots
import Sugar
import Compass
import Malibu
import OhMyAuth
import Imaginary

let spotsSession = SpotsSession()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: Window!

  lazy var toolbar = Toolbar(identifier: "main-toolbar")
  lazy var menuController = MenuController(cacheKey: "menu-cache")
  lazy var browseController = BrowseController(cacheKey: "main-screen-cache")
  var currentController: SpotsController?
  var splitView: MainSplitView!

  let configurators: [Configurator] = [
    SpotsConfigurator(),
    CompassConfigurator(),
    OhMyAuthConfigurator(),
    MalibuConfigurator(),
    ImaginaryConfigurator()
  ]

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    configurators.forEach { $0.configure() }

    if !spotsSession.isActive {
      spotsSession.login()
    } else {
      Malibu.networking("api").authenticate(bearerToken: spotsSession.accessToken ?? "")
    }

    splitView = MainSplitView(listView: menuController.view,
                  detailView: browseController.view)

    registerURLScheme()

    window.minSize = NSSize(width: 720, height: 640)
    window.contentView = splitView
    window.toolbar = toolbar
    window.becomeKeyWindow()

    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
  }
}
