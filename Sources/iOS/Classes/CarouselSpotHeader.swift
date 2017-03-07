import UIKit

/// A Carousel Spot Header
public class CarouselSpotHeader: UICollectionReusableView, Componentable {

  /// The preferred header height for the view
  public var preferredHeaderHeight: CGFloat = 120

  /// A UILabel that uses ComponentModel title for its text
  public lazy var titleLabel = UILabel()

  /// Initializes and returns a newly allocated view object with the specified frame rectangle.
  ///
  /// - parameter frame: The frame rectangle for the view, measured in points.
  ///
  /// - returns: An initialized view object.
  public override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
  }

  /// Init with coder
  ///
  /// - parameter aDecoder: An NSCoder
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Configure reusuable header view with ComponentModel.
  ///
  /// - parameter component: A ComponentModel struct used for configuring the view.
  public func configure(_ model: ComponentModel) {
    titleLabel.text = model.title
  }
}
