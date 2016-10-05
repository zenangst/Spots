import UIKit
import Fakery
import Compass
import Sugar
import Spots
import Brick

public func performAction(withURN urn: String) {
  let stringURL = "\(Compass.scheme)\(urn)"
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
    let url = URL(string: stringURL) else { return }

  appDelegate.handleURL(url)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

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

    window = UIWindow(frame: UIScreen.main.bounds)

    SpotsController.configure = {
      $0.backgroundColor = UIColor.white
    }

    ListSpot.register(PostTableViewCell.self, identifier: "feed")
    ListSpot.register(CommentTableViewCell.self, identifier: "comment")

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

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    return handleURL(url)
  }

  @discardableResult func handleURL(_ url: URL) -> Bool {
    guard let location = Compass.parse(url) else { return false }
    
    let route = location.path

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
        let faker = Faker()
        let post = Item(title: faker.name.name(),
            subtitle: subtitle,
            image: "http://lorempixel.com/75/75?type=avatar&id=1",
            kind: "feed",
            meta: ["media" : ["http://lorempixel.com/250/250/?type=attachment&id=1"]])
        let comments = FeedController.generateItems(0, to: 20, kind: "comment")

        var content = [post]
        content.append(contentsOf: comments)

        let feedComponent = Component(span: 1, items: content)
        let feedSpot = ListSpot(component: feedComponent)
        let controller = SpotsController(spots: [feedSpot])
        controller.title = "Feed"
        self.navigationController?.pushViewController(controller, animated: true)
      default:
        return false
      }

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

