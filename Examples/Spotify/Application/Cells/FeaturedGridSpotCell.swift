import Spots
import Imaginary
import Sugar
import Brick

open class FeaturedGridSpotCell: UICollectionViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 100, height: 120)

  lazy var imageView: UIImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    backgroundColor = UIColor.clear

    if item.image.isPresent {
      imageView.setImage(url: URL(string: item.image))
      imageView.frame.size = frame.size
    }

    if item.size.height == 0 {
      item.size = preferredViewSize
    }
  }
}
