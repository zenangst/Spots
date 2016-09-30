import UIKit

extension UIViewController {

  func spots_shouldAutorotate() -> Bool {
    if let parentViewController = parentViewController {
      return parentViewController.spots_shouldAutorotate()
    }

    return shouldAutorotate()
  }
}
