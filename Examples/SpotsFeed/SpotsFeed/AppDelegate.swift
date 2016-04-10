import UIKit
import Fakery
import Compass
import Sugar
import Spots
import Brick

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

    SpotsController.configure = {
      $0.backgroundColor = UIColor.whiteColor()
    }

    ListSpot.views["feed"] = PostTableViewCell.self
    ListSpot.views["comment"] = CommentTableViewCell.self

    let feedComponent = Component(span: 1, items: FeedController.generateItems(0, to: 3))
    let feedSpot = ListSpot(component: feedComponent)
    let controller = FeedController(spot: feedSpot)
    controller.title = "Feed"

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
        let post = ViewModel(title: Faker().name.name(),
            subtitle: subtitle,
            kind: "feed",
            image: "http://lorempixel.com/75/75?type=avatar&id=1",
            meta: ["media" : ["http://lorempixel.com/250/250/?type=attachment&id=1"]])
        let comments = FeedController.generateItems(0, to: 20, kind: "comment")

        var content = [post]
        content.appendContentsOf(comments)

        let feedComponent = Component(span: 1, items: content)
        let feedSpot = ListSpot(component: feedComponent)
        let controller = SpotsController(spots: [feedSpot])
        controller.title = "Feed"
        self.navigationController?.pushViewController(controller, animated: true)
      default:
        print("\(route) not captured")
      }
    }
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

