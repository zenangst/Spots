import Cocoa
import Spots
import Malibu
import AVFoundation

var blueprints: Blueprints = Blueprints()
let spotsSession = SpotsSession()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

  var window: Window?

  var history = [String]()

  let toolbarHeight: CGFloat = 36

  lazy var listController = ListController(cacheKey: "menu-cache")
  lazy var detailController = DetailController()

  var currentController: SpotsController?
  var mainWindowController: MainWindowController?
  var splitView: MainSplitView!
  var player: AVAudioPlayer?

  let configurators: [Configurator] = [
    BlueprintConfigurator(),
    CompassConfigurator(),
    ImaginaryConfigurator(),
    MalibuConfigurator(),
    OhMyAuthConfigurator(),
    SpotsConfigurator(),
  ]

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    configurators.forEach { $0.configure() }

//    spotsSession.login()

    if !spotsSession.isActive {
      spotsSession.login()
    } else {
      Malibu.networking("api").authenticate(bearerToken: spotsSession.accessToken ?? "")
    }

    if let window = window where window.frame.size.width < window.minSize.width {
      let previousRect = window.frame
      window.setFrame(NSRect(
        x: previousRect.origin.x,
        y: previousRect.origin.y,
        width: window.minSize.width,
        height: window.minSize.height
        ), display: false)
    }

    registerURLScheme()

    detailController.blueprint = blueprints["browse"]!

    window = Window()
    mainWindowController = MainWindowController(window: window)
    mainWindowController?.windowFrameAutosaveName = "MainWindow"
    window?.windowController = mainWindowController
    mainWindowController?.currentController = detailController
    AppDelegate.navigate("browse")
    mainWindowController?.showWindow(nil)

    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
  }
}
