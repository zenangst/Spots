import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)

    SpotsConfigurator().configure()

    let controller = ViewController(title: "Hello")
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}

