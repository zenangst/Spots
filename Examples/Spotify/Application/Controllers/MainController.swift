import Spots
import Sugar
import Compass
import Brick

class MainController: UITabBarController {

  lazy var playerController: PlayerController = {
    let list = ListSpot(component: Component(items: [Item(kind: "player", action: "openPlayer")]))
    let carousel = CarouselSpot(component: Component(span: 1))
    let player = ListSpot(component: Component(items: [Item(kind: "player")]))
    let playerButtons = GridSpot(component: Component(kind: "player", span: 3 ,items: [
      Item(title: "Previous", image: "previousButton", action: "previous"),
      Item(title: "Stop", image: "stopButton", action: "stop"),
      Item(title: "Next", image: "nextButton", action: "next")
      ]))
    
    player.tableView.separatorStyle = .none

    let controller = PlayerController(spots: [list, carousel, player, playerButtons])
    return controller
  }()

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

  lazy var profileController: UINavigationController = {
    let controller = ProfileController(title: localizedString("Profile"))
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.image = UIImage(named: "iconProfile")

    return navigationController
    }()

  lazy var searchController: UINavigationController = {
    let controller = SearchController(title: localizedString("Search"))
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.image = UIImage(named: "iconSearch")

    return navigationController
    }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()

    playerController.view.height = UIScreen.main.bounds.height + 60
    playerController.view.y = UIScreen.main.bounds.height
    myMusicController.view.addSubview(playerController.view)
  }

  func setupTabBar() {
    delegate = self
    tabBar.isTranslucent = true

    UITabBar.appearance().barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    UITabBar.appearance().tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)

    viewControllers = [
      myMusicController,
      featuredController,
      searchController,
      profileController
    ]

    selectedIndex = 0
  }
}

extension MainController: UITabBarControllerDelegate {

  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    playerController.view.removeFromSuperview()
    viewController.view.addSubview(playerController.view)
  }
}
