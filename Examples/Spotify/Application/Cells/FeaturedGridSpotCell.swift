import Spots
import Imaginary
import Sugar
import Brick

public class FeaturedGridSpotCell: UICollectionViewCell, SpotConfigurable {

  public var size = CGSize(width: 100, height: 120)

  lazy var imageView: UIImageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    backgroundColor = UIColor.clearColor()

    if item.image.isPresent {
      imageView.setImage(NSURL(string: item.image))
      imageView.frame.size = frame.size
    }

    if item.size.height == 0 {
      item.size = size
    }
  }
}
