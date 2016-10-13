import Spots
import Sugar
import Brick
import Imaginary

open class FeaturedFeedItemCell: UITableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 130)

  lazy var featuredImage = UIImageView(frame: CGRect.zero).then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  lazy var titleLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.boldSystemFont(ofSize: 18)
  }

  lazy var introLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.systemFont(ofSize: 13)
  }

  lazy var separatorView = UIView().then {
    $0.height = 1
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    selectionStyle = .none

    addSubview(featuredImage)
    addSubview(titleLabel)
    addSubview(introLabel)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    if let url = URL(string: item.image), !item.image.isEmpty {
      featuredImage.setImage(url)
    }

    featuredImage.width = contentView.frame.width - 30
    featuredImage.height = 200
    featuredImage.y = 15
    featuredImage.x = 15

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

    item.size.height = introLabel.frame.maxY + 15
  }
}
