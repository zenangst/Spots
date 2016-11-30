import UIKit
import Brick

/// A default cell for the CarouselSpot
public class CarouselSpotCell: UICollectionViewCell, SpotConfigurable {

  /// The preferred view size for the cell
  public var preferredViewSize: CGSize = CGSize(width: 88, height: 88)
  /// A weak referenced Item struct
  public var item: Item?

  /// A UILabel that will use Item.title as text
  public var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    label.textAlignment = .center

    return label
  }()

  /// A UIImageView that will use Item.image as its image
  lazy public var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.autoresizingMask = [.flexibleWidth]
    imageView.contentMode = .scaleAspectFill

    return imageView
  }()

  /// Initializes and returns a newly allocated view object with the specified frame rectangle.
  ///
  /// - parameter frame: The frame rectangle for the view, measured in points.
  ///
  /// - returns: An initialized view object.
  public override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, label].forEach { contentView.addSubview($0) }
  }

  /// Init with coder
  ///
  /// - parameter aDecoder: An NSCoder
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Configure cell with Item struct
  ///
  /// - parameter item: The Item struct that is used for configuring the view.
  public func configure(_ item: inout Item) {
    imageView.image = UIImage(named: item.image)
    imageView.frame = contentView.frame
    label.text = item.title
  }
}
