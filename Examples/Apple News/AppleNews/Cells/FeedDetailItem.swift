import Spots
import Sugar
import Imaginary

public class FeedDetailItemCell: UITableViewCell, ViewConfigurable {

  public var size = CGSize(width: 0, height: 180)

  lazy var featuredImage = UIImageView(frame: CGRect.zero).then {
    $0.contentMode = .ScaleAspectFill
    $0.clipsToBounds = true
  }

  lazy var titleLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.boldSystemFontOfSize(20)
  }

  lazy var introLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.systemFontOfSize(15)
  }

  lazy var separatorView = UIView().then {
    $0.frame.size.height = 1
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)

    selectionStyle = .None

    [featuredImage, titleLabel, introLabel].forEach { addSubview($0) }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    if !item.image.isEmpty {
      featuredImage.setImage(NSURL(string: item.image))
      featuredImage.frame.size.height = 300
    } else {
      featuredImage.frame.size.height = 0
    }

    featuredImage.frame.size.width = contentView.frame.width

    titleLabel.text = item.title
    titleLabel.frame.size.width = contentView.frame.width - 30
    titleLabel.sizeToFit()
    titleLabel.frame.origin.x = 15
    titleLabel.frame.origin.y = featuredImage.frame.maxY + 15

    introLabel.text = item.subtitle
    introLabel.frame.size.width = contentView.frame.width - 30
    introLabel.sizeToFit()
    introLabel.frame.origin.x = 15
    introLabel.frame.origin.y = titleLabel.frame.maxY + 15

    item.size.height = introLabel.frame.maxY - 30
  }
}
