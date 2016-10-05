import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)

    SpotFactory.register(kind: "cards", spot: CardSpot.self)
    CarouselSpot.register(CardSpotCell.self, identifier: "card")

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor(red:0.110, green:0.110, blue:0.110, alpha: 1)
    }

    SpotsController.configure = {
      $0.backgroundColor = UIColor.white
    }

    let controller = JSONController()

    controller.title = "Spots Cards".uppercased()

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

