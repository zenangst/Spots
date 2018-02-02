import UIKit

class ComponentTableView: UITableView {
  /// The component that the collection view belongs too.
  weak var component: Component?

  /// The default implementation of this method does nothing on iOS 5.1 and earlier.
  /// Otherwise, the default implementation uses any constraints you have set to determine
  /// the size and position of any subviews.
  /// It forwards the `layoutSubviews` to the `Component` it belongs too.
  override func layoutSubviews() {
    super.layoutSubviews()
    component?.layoutSubviews()
  }

  override var canBecomeFocused: Bool {
    return false
  }
}
