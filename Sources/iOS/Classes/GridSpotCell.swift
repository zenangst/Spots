import UIKit
import Brick

class GridSpotCell: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize = CGSize(width: 88, height: 88)
  var item: Item?

  var label: UILabel = {
    let label = UILabel()
    label.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    label.textAlignment = .center
    label.autoresizingMask = [.flexibleWidth]

    return label
  }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.autoresizingMask = [.flexibleWidth]

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
