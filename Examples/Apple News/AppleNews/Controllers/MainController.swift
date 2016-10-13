import UIKit

class MainController: UITabBarController {

  override var selectedIndex: Int {
    didSet {
      guard let viewControllers = viewControllers else { return }
      title = viewControllers[selectedIndex].title
    }
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    title = item.title
  }
}
