import UIKit
import Spots


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.white

    SpotsConfigurator().configure()

    let forYouController = ForYouController(title: "For You")
    let favoritesController = FavoritesController(title: "Favorites")
    let exploreController = ExploreController(title: "Explore")
    let searchController = SearchController(title: "Search")
    let savedController = SavedController(title: "Saved")
    let tabBarController = MainController()

    forYouController.tabBarItem.image = UIImage(named: "ForYou")
    favoritesController.tabBarItem.image = UIImage(named: "Favorites")
    exploreController.tabBarItem.image = UIImage(named: "Explore")
    searchController.tabBarItem.image = UIImage(named: "Search")
    savedController.tabBarItem.image = UIImage(named: "Saved")

    tabBarController.viewControllers = [
      forYouController,
      favoritesController,
      exploreController,
      searchController,
      savedController
    ]
    tabBarController.selectedIndex = 0
    tabBarController.tabBar.isTranslucent = true

    navigationController = UINavigationController(rootViewController: tabBarController)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }
}

