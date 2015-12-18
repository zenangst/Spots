import Spots
import Sugar
import Compass

class MainController: UITabBarController {

  lazy var player = PlayerView(frame: UIScreen.mainScreen().bounds)

  lazy var myMusicController: UINavigationController = {
    let controller = PlaylistController(playlistID: nil)
    let navigationController = UINavigationController(rootViewController: controller)
    controller.title = localizedString("My Music")

    return navigationController
    }()

  lazy var featuredController: UINavigationController = {
    let controller = FeaturedController(title: localizedString("Featured"))
    let navigationController = UINavigationController(rootViewController: controller)
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
    viewControllers = [
      featuredController,
      myMusicController
    ]

    tabBar.translucent = false
    tabBar.backgroundColor = .blackColor()
    tabBar.tintColor = UIColor.blackColor()

    selectedIndex = 0
  }
}
