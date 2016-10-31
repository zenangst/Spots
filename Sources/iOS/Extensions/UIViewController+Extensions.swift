#if os(iOS)
  import UIKit

  /// An extension to add rotation validation.
  extension UIViewController {
    /// Check if view controller should perform rotation.
    ///
    /// - Returns: Return boolean value to decide if view should rotate or not.
    public func spots_shouldAutorotate() -> Bool {
      if let parentViewController = parent {
        return parentViewController.spots_shouldAutorotate()
      }

      return shouldAutorotate
    }
  }
#endif
