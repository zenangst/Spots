import UIKit
import Spots
import Fakery

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var faker = Faker()
  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    ListSpot.headers["list"] = ListHeaderView.self
    ListSpot.configure = { tableView in
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    CarouselSpot.cells["topic"] = GridTopicCell.self

    let suggestedChannels = Component(span: 3, items: [
      ListItem(title: "Apple",   kind: "topic", image: suggestedImage(1)),
      ListItem(title: "Spotify", kind: "topic", image: suggestedImage(2)),
      ListItem(title: "Google",  kind: "topic", image: suggestedImage(3))
      ])

    let suggestedTopics = Component(span: 3, items: [
      ListItem(title: "Business", kind: "topic", image: topicImage("5A0E20", id: 1)),
      ListItem(title: "Software", kind: "topic", image: topicImage("760D26", id: 2)),
      ListItem(title: "News",     kind: "topic", image: topicImage("2266B5", id: 3)),
      ListItem(title: "iOS",      kind: "topic", image: topicImage("4CBCFB", id: 4))
      ])

    let browse = Component(title: "Browse", items: [
      ListItem(title: "News"),
      ListItem(title: "Business"),
      ListItem(title: "Politics"),
      ListItem(title: "Travel"),
      ListItem(title: "Technology"),
      ListItem(title: "Sports"),
      ListItem(title: "Science"),
      ListItem(title: "Entertainment"),
      ListItem(title: "Food")
      ])

    let components: [Spotable] = [
      TitleSpot(title: "Suggested Channels"),
      CarouselSpot(suggestedChannels,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
      TitleSpot(title: "Suggested Topics"),
      CarouselSpot(suggestedTopics,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
      ListSpot(component: browse)
    ]

    let controller = SpotsController(spots: components, refreshable: false)
    controller.title = "Explore"
    navigationController = UINavigationController(rootViewController: controller)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }

  func suggestedImage(id: Int) -> String {
    return faker.internet.image(width: 125, height: 160) + "?item=\(id)"
  }

  func topicImage(hex: String, id: Int) -> String {
    return faker.internet.templateImage(width: 125, height: 160, backColorHex: hex, frontColorHex: hex) + "?item=\(id)"
  }
}

