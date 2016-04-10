import UIKit
import Spots
import Compass
import Sugar
import Keychain
import Cache
import Hue
import Brick

let keychainAccount = "spots-accessToken"
var username: String? {
set(value) {
  NSUserDefaults.standardUserDefaults().setValue(value, forKey: "username")
  NSUserDefaults.standardUserDefaults().synchronize()
}
get {
  return NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var cache = Cache<SPTSession>(name: "Spotify")
  lazy var mainController: MainController = MainController()

  lazy var authController: UINavigationController = {
    let controller = AuthController(spot: ListSpot().then {
      $0.items = [ViewModel(title: "Auth", action: "auth", kind: "playlist", size: CGSize(width: 120, height: 88))]
      }
    )
    controller.title = "Spotify".uppercaseString

    let navigationController = UINavigationController(rootViewController: controller)
    return navigationController
  }()

  let configurators: [Configurator.Type] = [
    SpotifyConfigurator.self,
    CompassConfigurator.self,
    SpotsConfigurator.self
  ]

  var session: SPTSession? {
    didSet {
      guard let session = session else { return }

      mainController.playerController.player.loginWithSession(session, callback: { (error) -> Void in
        if let _ = error {
          self.session = nil
          self.cache.remove("session")
          self.window?.rootViewController = self.authController
        }
      })
    }
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    configurators.forEach { $0.configure() }
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    window?.rootViewController = authController

    cache.object("session") { (session: SPTSession?) -> Void in
      dispatch {
        guard let session = session else { return }
        self.session = session
        self.window?.rootViewController = self.mainController
      }
    }

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  func applyStyles() {
    UIApplication.sharedApplication().statusBarStyle = .LightContent

    UINavigationBar.appearance().then {
      $0.barTintColor = UIColor.hex("#000")
      $0.tintColor = UIColor.hex("#fff")
      $0.shadowImage = UIImage()
      $0.titleTextAttributes = [
        NSForegroundColorAttributeName: UIColor.hex("#fff")
      ]
    }
  }

  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    if session == nil {
      return PreLoginRouter().navigate(url, navigationController: authController)
    }

    guard let navigationController = mainController.selectedViewController as? UINavigationController
      else { return false }

    return PostLoginRouter().navigate(url, navigationController: navigationController)
  }
}
