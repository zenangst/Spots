import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SpotsDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    ListSpot.headers["list"] = ListHeaderView.self
    GridSpot.cells["topic"] = GridTopicCell.self

    var suggestedChannels = Component(span: 3)
    suggestedChannels.items = [
      ListItem(title: "Business", kind: "topic"),
      ListItem(title: "Software", kind: "topic"),
      ListItem(title: "News", kind: "topic"),
    ]

    var browse = Component(["title" : "Browse", "type" : "list"])
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

    let carousel = CarouselSpot(component: suggestedChannels)
    carousel.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
    carousel.flowLayout.minimumInteritemSpacing = 15

    let components: [Spotable] = [
      ListSpot(component: Component(["title" : "Suggested Topics", "type" : "list"])),
      carousel,
      ListSpot(component: browse)
    ]

    let controller = SpotsController(spots: components)
    controller.spotDelegate = self
    controller.title = "Explore"
    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    print(spot)
    print(item)
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

