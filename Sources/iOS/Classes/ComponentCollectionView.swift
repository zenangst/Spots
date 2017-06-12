import UIKit

/// ComponentCollectionView is a very simple subclass of UICollectionView.
/// The purpose of this class is to forward `layoutSubviews` to the `Component`.
/// This is used to perform infinite scrolling for horizontal layouts.
class ComponentCollectionView: UICollectionView, UIGestureRecognizerDelegate {

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
}
