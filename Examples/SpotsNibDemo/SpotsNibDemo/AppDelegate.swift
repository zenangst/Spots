import UIKit
import Spots
import Brick
import Hue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor(hex: "13151A")

    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

    let navigationBar = UINavigationBar.appearance()
    navigationBar.isTranslucent = false
    navigationBar.barTintColor = UIColor(hex: "181B23")
    navigationBar.tintColor = UIColor(hex: "181B23")
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor(hex: "465771")
    ]
    navigationBar.setBackgroundImage(nil, for: .default)

    ListSpot.register(UINib(nibName: "CustomList", bundle: Bundle.main), identifier: "custom-list")
    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor(hex: "181B23")
      tableView.separatorInset = UIEdgeInsets(
        top: 0, left: 7.5,
        bottom: 0, right: 7.5)
      tableView.layoutMargins = EdgeInsets.zero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorColor = UIColor(hex: "465771")
    }

    let component = Component(title: "Browse", items: [
      Item(
        title: "First cell",
        subtitle: "This is an example of a .nib being used in Spots",
        kind: "custom-list",
        meta: ["toggle" : true]),
      Item(
        title: "Second example",
        subtitle: "This is just to show how it works",
        kind: "custom-list",
        meta: ["toggle" : false])
      ]
    )

    let spots: [Spotable] = [ListSpot(component: component)]
    let controller = SpotsController(cacheKey: "nib-demo")

    controller.spots = spots
    controller.cache()
    controller.title = "Spots .nib feature".uppercased()
    let navigationController = UINavigationController(rootViewController: controller)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }

}

