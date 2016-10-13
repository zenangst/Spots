#if os(iOS)
  import UIKit

  extension UIViewController {

    /// Check if view controller should perform rotation.
    ///
    /// - returns: Return boolean value to decide if view should rotate or not.
    func spots_shouldAutorotate() -> Bool {
      if let parentViewController = parent {
        return parentViewController.spots_shouldAutorotate()
      }

      return shouldAutorotate
    }
  }
#endif
