import UIKit

class MainController: UITabBarController {

  override var selectedIndex: Int {
    didSet {
      guard let viewControllers = viewControllers else { return }
      title = viewControllers[selectedIndex].title
    }
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    title = item.title
  }
}
