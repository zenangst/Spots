import UIKit
import Fakery
import Compass
import Sugar

public func action(urn: String) {
  let stringURL = "\(Compass.scheme)\(urn)"
  guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
    url = NSURL(string: stringURL) else { return }

  appDelegate.handleURL(url)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    Compass.scheme = Application.mainScheme!
    Compass.routes = [
      "feed:author:{id}",
      "feed:action:like:{id}",
      "feed:action:unlike:{id}",
      "feed:author:{id}",
      "feed:comment:{id}",
      "feed:media:{id}",
      "feed:post:{id}"
    ]

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    FeedSpot.cells["feed"] = PostTableViewCell.self
    FeedSpot.cells["comment"] = CommentTableViewCell.self

    let feedComponent = Component(span: 1, items: generateItems(0, to: 20))
    var browse = Component(title: "Quick links", kind: "list")
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
    let feedSpot = FeedSpot(component: feedComponent)
    let components: [Spotable] = [
      feedSpot
    ]

    let controller = SpotsController(spots: components)

    controller.spotDelegate = self
    controller.title = "Feed"
    controller.collectionView.scrollEnabled = false

    applyStyles()
    
    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }

  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return handleURL(url)
  }

  func handleURL(url: NSURL) -> Bool {
    return Compass.parse(url) { [unowned self] route, arguments in
      switch route {
      case "feed:author:{id}":
        print("👤")
      case "feed:action:like:{id}":
        print("👍")
      case "feed:action:unlike:{id}":
        print("👎")
      case "feed:comment:{id}":
        print("💬")
      case "feed:media:{id}":
        print("🖼")
      case "feed:post:{id}":
        let sencenceCount = Int(arc4random_uniform(8) + 1)
        let subtitle = Faker().lorem.sentences(amount: sencenceCount) + " " + Faker().internet.url()
        let post = ListItem(title: Faker().name.name(),
            subtitle: subtitle,
            kind: "feed",
            image: "http://lorempixel.com/75/75?type=avatar&id=1",
            meta: ["media" : ["http://lorempixel.com/250/250/?type=attachment&id=1"]])
        let comments = self.generateItems(0, to: 10, kind: "comment")

        var content = [post]
        content.appendContentsOf(comments)
        
        let feedComponent = Component(span: 1, items: content)
        let feedSpot = FeedSpot(component: feedComponent)
        let controller = SpotsController(spots: [feedSpot])
        controller.title = "Feed"
        self.navigationController?.pushViewController(controller, animated: true)
      default:
        print("\(route) not captured")
      }
    }
  }

  func generateItems(from: Int, to: Int, kind: String = "feed") -> [ListItem] {
    var items = [ListItem]()
      for i in from...to {
        autoreleasepool({
          items.append(generateItem(i))
        })
      }
    return items
  }

  func generateItem(index: Int, kind: String = "feed") -> ListItem {
    let sencenceCount = Int(arc4random_uniform(8) + 1)
    let subtitle = Faker().lorem.sentences(amount: sencenceCount) + " " + Faker().internet.url()

    let mediaCount = Int(arc4random_uniform(5) + 1)
    var mediaStrings = [String]()
    for x in 0..<mediaCount {
      mediaStrings.append("http://lorempixel.com/250/250/?type=attachment&id=\(index)\(x)")
    }

    return ListItem(title: Faker().name.name(),
      subtitle: subtitle,
      kind: kind,
      image: "http://lorempixel.com/75/75?type=avatar&id=\(index)",
      meta: ["media" : mediaStrings])
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

extension AppDelegate: SpotsDelegate {

  func spotDidRefresh(spot: Spotable, refreshControl: UIRefreshControl) {
    delay(0.5) {
      refreshControl.endRefreshing()

      if let controller = self.navigationController?.visibleViewController as? SpotsController {
        controller.updateSpotAtIndex(0, closure: { (spot: Spotable) -> Spotable in
          spot.component.items.insert(self.generateItem(10), atIndex: 0)
          return spot
        })
      }
    }
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) { }

}

