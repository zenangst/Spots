import Spots
import Imaginary
import Sugar
import Brick

public class PlayerGridSpotCell: UICollectionViewCell, SpotConfigurable {

  public var size = CGSize(width: 125, height: 100)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
    $0.tintColor = UIColor.whiteColor()
  }

  lazy var textLabel = UILabel().then {
    $0.textColor = UIColor.whiteColor()
    $0.textAlignment = .Center
    $0.font = UIFont.systemFontOfSize(14)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, textLabel].forEach { addSubview($0) }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    backgroundColor = UIColor.clearColor()

    if item.image.isPresent {
      imageView.frame.size = CGSize(width: 32, height: 32)
      imageView.x = (width - imageView.frame.width) / 2
      imageView.y = (height - imageView.frame.height) / 2
      imageView.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
      textLabel.y = imageView.y + 20
    }

    imageView.tintColor = item.meta("tintColor", UIColor.whiteColor())
    textLabel.textColor = item.meta("textColor", UIColor.whiteColor())

    textLabel.text = item.title
    textLabel.width = width
    textLabel.height = 48

    item.size = size
  }
}
