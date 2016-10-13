import Spots
import Sugar
import Imaginary
import Brick

open class FeedDetailItemCell: UITableViewCell, SpotConfigurable {
  open var preferredViewSize: CGSize = CGSize(width: 0, height: 180)

  lazy var featuredImage = UIImageView(frame: CGRect.zero).then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  lazy var titleLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.boldSystemFont(ofSize: 20)
  }

  lazy var introLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.systemFont(ofSize: 15)
  }

  lazy var separatorView = UIView().then {
    $0.height = 1
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    selectionStyle = .none

    [featuredImage, titleLabel, introLabel].forEach { addSubview($0) }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    if !item.image.isEmpty {
      featuredImage.setImage(URL(string: item.image))
      featuredImage.height = 300
    } else {
      featuredImage.height = 0
    }

    featuredImage.width = contentView.frame.width

    titleLabel.text = item.title
    titleLabel.width = contentView.frame.width - 30
    titleLabel.sizeToFit()
    titleLabel.x = 15
    titleLabel.y = featuredImage.frame.maxY + 15

    introLabel.text = item.subtitle
    introLabel.width = contentView.frame.width - 30
    introLabel.sizeToFit()
    introLabel.x = 15
    introLabel.y = titleLabel.frame.maxY + 15

    item.size.height = introLabel.frame.maxY - 30
  }
}
