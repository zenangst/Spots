import Spots
import Sugar
import Compass
import Brick

class MainController: UITabBarController {

  lazy var playerController = PlayerController(spots: [
    ListSpot().then { $0.items = [ViewModel(kind: "player", action: "openPlayer")] },
    CarouselSpot(Component(span: 1)),
    ListSpot(component: Component(items: [
      ViewModel(kind: "player")
      ])).then {
        $0.tableView.separatorStyle = .None
    },
    GridSpot(component: Component(span: 3, kind: "player" ,items: [
      ViewModel(title: "Previous", image: "previousButton", action: "previous"),
      ViewModel(title: "Stop", image: "stopButton", action: "stop"),
      ViewModel(title: "Next", image: "nextButton", action: "next")
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

    playerController.view.height = UIScreen.mainScreen().bounds.height + 60
    playerController.view.y = UIScreen.mainScreen().bounds.height
    myMusicController.view.addSubview(playerController.view)
  }

  func setupTabBar() {
    delegate = self
    tabBar.translucent = true

    UITabBar.appearance().then {
      $0.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
      $0.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    }

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

  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    playerController.view.removeFromSuperview()
    viewController.view.addSubview(playerController.view)
  }
}
