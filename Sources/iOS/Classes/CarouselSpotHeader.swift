import UIKit

/// A Carousel Spot Header
class CarouselSpotHeader: UICollectionReusableView, Componentable {

  /// The preferred header height for the view
  var preferredHeaderHeight: CGFloat = 120

  /// A UILabel that uses Component title for its text
  lazy var titleLabel = UILabel()

  /// Initializes and returns a newly allocated view object with the specified frame rectangle.
  ///
  /// - parameter frame: The frame rectangle for the view, measured in points.
  ///
  /// - returns: An initialized view object.
  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
  }

  /// Init with coder
  ///
  /// - parameter aDecoder: An NSCoder
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Configure reusuable header view with Component.
  ///
  /// - parameter component: A Component struct used for configuring the view.
  func configure(_ component: Component) {
    titleLabel.text = component.title
  }
}
