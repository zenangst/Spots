import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let controller = CompositionController()

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = controller

    controller.reloadIfNeeded(CompositionController.components)
    controller.scrollView.backgroundColor = UIColor.green.withAlphaComponent(0.2)

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
    }

    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
    }

    window?.makeKeyAndVisible()

    return true
  }
}
