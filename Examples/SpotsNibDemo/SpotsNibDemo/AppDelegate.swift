import UIKit
import Spots
import Brick
import Hue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.hex("13151A")

    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

    let navigationBar = UINavigationBar.appearance()
    navigationBar.translucent = false
    navigationBar.barTintColor = UIColor.hex("181B23")
    navigationBar.tintColor = UIColor.hex("181B23")
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.hex("465771")
    ]
    navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)

    ListSpot.register(nib: UINib(nibName: "CustomList", bundle: NSBundle.mainBundle()), identifier: "custom-list")
    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor.hex("181B23")
      tableView.separatorInset = UIEdgeInsets(
        top: 0, left: 7.5,
        bottom: 0, right: 7.5)
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorColor = UIColor.hex("465771")
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

    let spots: [Spotable] = [
      ListSpot(component: component)
    ]

    let controller = SpotsController(spots: spots)
    controller.title = "Spots .nib feature".uppercaseString
    let navigationController = UINavigationController(rootViewController: controller)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }

}

