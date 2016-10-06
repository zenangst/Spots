import Cocoa
import Spots
import Malibu
import AVFoundation

var blueprints: Blueprints = Blueprints()
let spotsSession = SpotsSession()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

  let toolbarHeight: CGFloat = 36

  lazy var listController = ListController(cacheKey: "menu-cache")
  lazy var detailController: DetailController = DetailController([:])

  var volumeTimer: Timer?
  var window: Window?
  var player: AVAudioPlayer?
  var history = [String]()
  var currentController: Controller?
  var mainWindowController: MainWindowController?
  var splitView: MainSplitView!

  let configurators: [Configurator] = [
    BlueprintConfigurator(),
    CompassConfigurator(),
    ImaginaryConfigurator(),
    MalibuConfigurator(),
    OhMyAuthConfigurator(),
    SpotsConfigurator(),
  ]

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    configurators.forEach { $0.configure() }

//    spotsSession.login()

    if !spotsSession.isActive {
      spotsSession.login()
    } else {
      Malibu.networking("api").authenticate(bearerToken: spotsSession.accessToken ?? "")
    }

    if let window = window , window.frame.size.width < window.minSize.width {
      let previousRect = window.frame
      window.setFrame(NSRect(
        x: previousRect.origin.x,
        y: previousRect.origin.y,
        width: window.minSize.width,
        height: window.minSize.height
        ), display: false)
    }

    registerURLScheme()

    window = Window()
    mainWindowController = MainWindowController(window: window)
    mainWindowController?.windowFrameAutosaveName = "MainWindow"
    window?.windowController = mainWindowController
    mainWindowController?.currentController = detailController
    mainWindowController?.showWindow(nil)

//    UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
  }
}
