import UIKit
import Fakery

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    ListSpot.cells["feed"] = PostTableViewCell.self

    let feedComponent = Component(span: 1, items: generateItems(0, to: 3))
    let feedSpot = ListSpot(component: feedComponent)
    let browse = Component(title: "Browse",
      kind: "list",
      items: [
        ListItem(title: "News"),
        ListItem(title: "Business"),
        ListItem(title: "Politics"),
        ListItem(title: "Travel")
      ]
    )

    let components: [Spotable] = [
      feedSpot,
      ListSpot(component: browse)
    ]

    let controller = SpotsController(spots: components)
    controller.title = "Feed"

    applyStyles()
    
    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }

  func generateItems(from: Int, to: Int) -> [ListItem] {
    var items = [ListItem]()
      for i in from...to {
        autoreleasepool({
          let sencenceCount = Int(arc4random_uniform(8) + 1)
          let subtitle = Faker().lorem.sentences(amount: sencenceCount) + " " + Faker().internet.url()
          items.append(
            ListItem(title: Faker().name.name(),
              subtitle: subtitle,
              kind: "feed",
              image: "http://lorempixel.com/250/250/?type=attachment&id=\(i)",
              meta: ["avatar" : "http://lorempixel.com/75/75?type=avatar&id=\(i)"])
          )
        })
      }
    return items
  }

  func applyStyles() {
    UIApplication.sharedApplication().statusBarStyle = .LightContent

    let navigationBar = UINavigationBar.appearance()
    navigationBar.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    navigationBar.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    navigationBar.shadowImage = UIImage()
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    ]
  }
}

