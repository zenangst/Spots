import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)

    GridSpot.register(GridSpotHeader.self, identifier: "header")
    GridSpot.register(GridSpotCellTitles.self, identifier: "titles")
    GridSpot.register(GridSpotCellCircle.self, identifier: "circle")

    SpotsController.configure = {
      $0.backgroundColor = UIColor.white
    }

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.white
    }

    let controller = JSONController()

    controller.title = "Spots".uppercased()

    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  func applyStyles() {
    UIApplication.shared.statusBarStyle = .lightContent

    let navigationBar = UINavigationBar.appearance()
    navigationBar.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    navigationBar.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    navigationBar.shadowImage = UIImage()
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    ]
  }
}

