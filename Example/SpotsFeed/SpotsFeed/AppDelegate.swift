import UIKit
import Fakery

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    ListSpot.cells["feed"] = PostTableViewCell.self

    let feedComponent = Component(span: 1, items: [
      ListItem(title: "Apple", kind: "feed", image: "http://lorempixel.com/125/160/?type=attachment&id=1"),
      ListItem(title: "Spotify", kind: "feed",image: "http://lorempixel.com/125/160/?type=attachment&id=2"),
      ListItem(title: "Google", kind: "feed", image: "http://lorempixel.com/125/160/?type=attachment&id=3")
      ])

    let feedSpot = ListSpot(component: feedComponent)

    var browse = Component(title: "Browse", kind: "list")
    browse.items = [
      ListItem(title: "News"),
      ListItem(title: "Business"),
      ListItem(title: "Politics"),
      ListItem(title: "Travel"),
      ListItem(title: "Technology"),
      ListItem(title: "Sports"),
      ListItem(title: "Science"),
      ListItem(title: "Entertainment"),
      ListItem(title: "Food")
    ]

    let components: [Spotable] = [
      TitleSpot(title: "Featured items"),
      feedSpot,
      ListSpot(component: browse)
    ]

    let controller = SpotsController(spots: components)
    controller.title = "Explore"
    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController

    window?.makeKeyAndVisible()

    return true
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

