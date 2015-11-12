import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    ListSpot.headers["list"] = ListHeaderView.self
    CarouselSpot.cells["topic"] = GridTopicCell.self

    let suggestedChannels = Component(span: 3, items: [
      ListItem(title: "Apple", kind: "topic", image: "http://lorempixel.com/125/160/?type=attachment&id=1"),
      ListItem(title: "Spotify", kind: "topic",image: "http://lorempixel.com/125/160/?type=attachment&id=2"),
      ListItem(title: "Google", kind: "topic", image: "http://lorempixel.com/125/160/?type=attachment&id=3")
      ])

    let suggestedTopics = Component(span: 3, items: [
      ListItem(title: "Business", kind: "topic", meta: ["background-color" : "5A0E20"]),
      ListItem(title: "Software", kind: "topic", meta: ["background-color" : "760D26"]),
      ListItem(title: "News", kind: "topic", meta: ["background-color" : "2266B5"]),
      ListItem(title: "iOS", kind: "topic", meta: ["background-color" : "4CBCFB"])
      ])

    let suggestedChannelSpot = CarouselSpot(suggestedChannels,
      top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15)
    let suggestedTopicsSpot = CarouselSpot(suggestedTopics,
      top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15)

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
      TitleSpot(title: "Suggested Channels"),
      suggestedChannelSpot,
      TitleSpot(title: "Suggested Topics"),
      suggestedTopicsSpot,
      ListSpot(component: browse)
    ]

    let controller = SpotsController(spots: components)
    controller.title = "Explore"
    navigationController = UINavigationController(rootViewController: controller)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }
}

