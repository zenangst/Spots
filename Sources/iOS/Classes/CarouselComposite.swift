import UIKit

/// A proxy cell that is used for composite views inside other CoreComponent objects
class CarouselComposite: UICollectionViewCell, Composable {

  /// Performs any clean up necessary to prepare the view for use again.
  override func prepareForReuse() {
    for case let view as ScrollableView in contentView.subviews {
      view.removeFromSuperview()
    }
  }
}
