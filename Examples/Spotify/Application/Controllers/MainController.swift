import Spots
import Sugar
import Compass

class MainController: UITabBarController {

  lazy var playerController = PlayerController(spots: [
    ListSpot(component: Component(items: [
      ListItem(kind: "player", action: "openPlayer")
      ])),
    CarouselSpot(Component(span: 1)),
    ListSpot(component: Component(items: [
      ListItem()
      ])),
    GridSpot(component: Component(span: 3, kind: "player" ,items: [
      ListItem(title: "Previous", image: "previousButton", action: "previous"),
      ListItem(title: "Stop", image: "stopButton", action: "stop"),
      ListItem(title: "Next", image: "nextButton", action: "next")
      ]))
    ])

  lazy var myMusicController: UINavigationController = {
    let controller = PlaylistController(playlistID: nil)
    let navigationController = UINavigationController(rootViewController: controller)
    controller.title = localizedString("My Music")
    controller.tabBarItem.image = UIImage(named: "iconMyMusic")

    return navigationController
    }()

  lazy var featuredController: UINavigationController = {
    let controller = FeaturedController(title: localizedString("Featured"))
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.image = UIImage(named: "iconFeatured")

    return navigationController
    }()

  lazy var settingsController: UINavigationController = {
    let controller = UIViewController()
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.image = UIImage(named: "iconSettings")
    controller.title = localizedString("Settings")

    return navigationController
    }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()

    playerController.view.frame.size.height = UIScreen.mainScreen().bounds.height + 60
    playerController.view.frame.origin.y = UIScreen.mainScreen().bounds.height
    myMusicController.view.addSubview(playerController.view)
  }

  func setupTabBar() {
    delegate = self
    tabBar.translucent = true

    let navigationBar = UITabBar.appearance()
    navigationBar.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    navigationBar.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)

    viewControllers = [
      myMusicController,
      featuredController,
      settingsController
    ]

    selectedIndex = 0
  }
}

extension MainController: UITabBarControllerDelegate {

  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    playerController.view.removeFromSuperview()
    viewController.view.addSubview(playerController.view)
  }
}
