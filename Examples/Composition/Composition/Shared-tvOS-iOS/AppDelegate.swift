import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    ListSpot.register(header: CompositionListHeader.self, identifier: "header")
    ListSpot.register(view: CompositionListView.self, identifier: "view")

    let controller = CompositionController()

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = controller

    controller.reloadIfNeeded(CompositionController.components)

    window?.makeKeyAndVisible()

    return true
  }
}
