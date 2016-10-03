#if os(iOS)
import UIKit

extension UIViewController {

  func spots_shouldAutorotate() -> Bool {
    if let parentViewController = parent {
      return parentViewController.spots_shouldAutorotate()
    }

    return shouldAutorotate
  }
}
#endif
