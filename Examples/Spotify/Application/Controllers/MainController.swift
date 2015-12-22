import Spots
import Sugar
import Compass

class MainController: UITabBarController {

  lazy var player = PlayerView(frame: UIScreen.mainScreen().bounds)

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
    //featuredController.container.contentInset.bottom = 44

    return navigationController
    }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()

    player.frame.origin.y = UIScreen.mainScreen().bounds.height - 60
    //view.addSubview(player)
  }

  func setupTabBar() {
    tabBar.translucent = false

    let navigationBar = UITabBar.appearance()
    navigationBar.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    navigationBar.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)

    viewControllers = [
      featuredController,
      myMusicController
    ]

    selectedIndex = 0
  }
}
