import UIKit
import Brick

/// A default cell for the CarouselSpot
class CarouselSpotCell: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 88, height: 88)
  var item: Item?

  var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    label.textAlignment = .center

    return label
  }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.autoresizingMask = [.flexibleWidth]
    imageView.contentMode = .scaleAspectFill

    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, label].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {
    imageView.image = UIImage(named: item.image)
    imageView.frame = contentView.frame
    label.text = item.title
  }
}
