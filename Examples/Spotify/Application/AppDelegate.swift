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
  UserDefaults.standard.setValue(value, forKey: "username")
  UserDefaults.standard.synchronize()
}
get {
  return UserDefaults.standard.value(forKey: "username") as? String
}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var cache: Cache<SPTSession> = Cache<SPTSession>(name: "Spotify")
  lazy var mainController: MainController = MainController()

  lazy var authController: UINavigationController = {
    let controller = AuthController(spot: ListSpot().then {
      $0.items = [Item(title: "Auth", kind: "playlist", action: "auth", size: CGSize(width: 120, height: 88))]
      }
    )
    controller.title = "Spotify".uppercased()

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

      mainController.playerController.player.login(with: session, callback: { (error) -> Void in
        if let _ = error {
          self.session = nil
          self.cache.remove("session")
          self.window?.rootViewController = self.authController
        }
      })
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    configurators.forEach { $0.configure() }
    window = UIWindow(frame: UIScreen.main.bounds)

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
    UIApplication.shared.statusBarStyle = .lightContent
    UINavigationBar.appearance().barTintColor = UIColor(hex:"#000")
    UINavigationBar.appearance().tintColor = UIColor(hex:"#fff")
    UINavigationBar.appearance().shadowImage = UIImage()
    UINavigationBar.appearance().titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor(hex:"#fff")
    ]
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    if session == nil {
      return PreLoginRouter().navigate(url, navigationController: authController)
    }

    guard let navigationController = mainController.selectedViewController as? UINavigationController
      else { return false }

    return PostLoginRouter().navigate(url, navigationController: navigationController)
  }
}
