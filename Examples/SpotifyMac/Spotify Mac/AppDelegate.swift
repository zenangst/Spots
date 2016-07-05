import Cocoa
import Spots
import Malibu
import AVFoundation

var blueprints: Blueprints = Blueprints()
let spotsSession = SpotsSession()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

  @IBOutlet weak var window: Window!

  var history = [String]()

  let toolbarHeight: CGFloat = 36

  lazy var listController = ListController(cacheKey: "menu-cache")
  lazy var detailController = DetailController()

  var currentController: SpotsController?
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

    if !spotsSession.isActive {
      spotsSession.login()
    } else {
      Malibu.networking("api").authenticate(bearerToken: spotsSession.accessToken ?? "")
    }

    window.delegate = self

    splitView = MainSplitView(listView: listController.view,
                  detailView: detailController.view)

    registerURLScheme()

    detailController.blueprint = blueprints["browse"]!

    window.contentView = splitView
    window.becomeKeyWindow()

    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
  }
}
