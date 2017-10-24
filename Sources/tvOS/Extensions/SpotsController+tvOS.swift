import UIKit

// An extension for SpotsController to make it easier to configure and access `UIFocusGuide`.
extension SpotsController {
  // A convenience method for resolving the focus guides preferred focused view
  public var focusGuidePreferredView: UIView? {
    set {
      if #available(tvOS 10.0, *) {
        focusGuide.preferredFocusEnvironments = [view]
      } else {
        focusGuide.preferredFocusedView = view
      }
    }
    get {
      if #available(tvOS 10.0, *) {
        return focusGuide.preferredFocusEnvironments.first as? UIView
      } else {
        return focusGuide.preferredFocusedView
      }
    }
  }

  /// Add and constrain the focus guide to a given view.
  /// The default view in `viewDidLoad` of the `SpotsController` is
  /// the controllers scrollview.
  ///
  /// - Parameters:
  ///   - focusGuide: The focus guide that should be added to the view.
  ///   - view: The view that should own the focus guide.
  ///   - enabled: Determines if the focus guide should be enabled or not, it defaults to `false`.
  func configure(focusGuide: UIFocusGuide, for view: UIView, enabled: Bool = false) {
    focusGuide.isEnabled = enabled
    view.addLayoutGuide(focusGuide)
    focusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    focusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    focusGuide.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    focusGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }
}
