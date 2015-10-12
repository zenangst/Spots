import UIKit
import GoldenRetriever
import Sugar

public class PagesSpot: NSObject, Spotable {

  public static var controllers = [String: UIViewController.Type]()
  public static var height: CGFloat = 125

  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?

  public private(set) var currentIndex = 0

  private var pageViewController: UIPageViewController!
  lazy private var pages = Array<UIViewController>()

  public required init(component: Component) {
    self.component = component
    super.init()

    pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageViewController.delegate = self
    pageViewController.dataSource = self

    for item in component.items {
      let controllerClass = PagesSpot.controllers[item.kind] ?? UIViewController.self
      // Itemble

    }
    goTo(0)
  }

  public func render() -> UIView {
    return pageViewController.view
  }

  public func layout(size: CGSize) {
    pageViewController.view.frame.size.width = UIScreen.mainScreen().bounds.width
    pageViewController.view.frame.size.height = PagesSpot.height
  }
}

// MARK: - Navigation

extension PagesSpot {

  public func goTo(index: Int) {
    if index >= 0 && index < pages.count {
      let direction: UIPageViewControllerNavigationDirection = (index > currentIndex) ? .Forward : .Reverse
      let viewController = pages[index]
      currentIndex = index
      pageViewController.setViewControllers([viewController],
        direction: direction,
        animated: true,
        completion: nil)
    }
  }

  public func next() {
    goTo(currentIndex + 1)
  }

  public func previous() {
    goTo(currentIndex - 1)
  }
}

// MARK: UIPageViewControllerDataSource

extension PagesSpot: UIPageViewControllerDataSource {

  public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

    let index = pages.indexOf(viewController)?.predecessor()
    return pages.at(index)
  }

  public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let index: Int? = pages.indexOf(viewController)?.successor()
    return pages.at(index)
  }

  public func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pages.count
  }

  public func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return currentIndex
  }
}

// MARK: UIPageViewControllerDelegate

extension PagesSpot : UIPageViewControllerDelegate {

  public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
    previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      if completed {
        if let viewController = pageViewController.viewControllers?.last,
          index = pages.indexOf(viewController) {
            currentIndex = index
        }
      }
  }
}

extension Array {

  func at(index: Int?) -> Element? {
    if let index = index where index >= 0 && index < endIndex {
      return self[index]
    } else {
      return nil
    }
  }
}
