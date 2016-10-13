import Spots
import Imaginary
import Sugar
import Brick

open class PlayerGridSpotCell: UICollectionViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 125, height: 100)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.tintColor = UIColor.white
  }

  lazy var textLabel = UILabel().then {
    $0.textColor = UIColor.white
    $0.textAlignment = .center
    $0.font = UIFont.systemFont(ofSize: 14)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, textLabel].forEach { addSubview($0) }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    backgroundColor = UIColor.clear

    if item.image.isPresent {
      imageView.frame.size = CGSize(width: 32, height: 32)
      imageView.x = (width - imageView.frame.width) / 2
      imageView.y = (height - imageView.frame.height) / 2
      imageView.image = UIImage(named: item.image)?.withRenderingMode(.alwaysTemplate)
      textLabel.y = imageView.y + 20
    }

    imageView.tintColor = item.meta("tintColor", UIColor.white)
    textLabel.textColor = item.meta("textColor", UIColor.white)

    textLabel.text = item.title
    textLabel.width = width
    textLabel.height = 48

    item.size = preferredViewSize
  }
}
