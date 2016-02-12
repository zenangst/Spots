import Spots
import Imaginary
import Sugar

public class PlayerGridSpotCell: UICollectionViewCell, ViewConfigurable {

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

    if !item.image.isEmpty {
      imageView.frame.size = CGSize(width: 32, height: 32)
      imageView.frame.origin.x = (frame.size.width - imageView.frame.width) / 2
      imageView.frame.origin.y = (frame.size.height - imageView.frame.height) / 2
      imageView.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
      textLabel.frame.origin.y = imageView.frame.origin.y + 20
    }

    if let tintColor = item.meta["tintColor"] as? UIColor {
      imageView.tintColor = tintColor
    }

    if let textColor = item.meta["textColor"] as? UIColor {
      textLabel.textColor = textColor
    }

    textLabel.text = item.title
    textLabel.frame.size.width = frame.size.width
    textLabel.frame.size.height = 48

    item.size = size
  }
}
