import Spots
import Sugar
import Imaginary
import Brick

class FeedItemCell: UITableViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 130)

  lazy var customImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).then {
    $0.contentMode = .scaleAspectFill
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .left
    $0.firstLineHeadIndent = 5.0
    $0.headIndent = 5.0
    $0.tailIndent = 0.0
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    textLabel?.numberOfLines = 0
    textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    detailTextLabel?.numberOfLines = 0
    detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    accessoryView = customImageView

    selectionStyle = .none
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {
    if !item.image.isEmpty {
      customImageView.setImage(NSURL(string: item.image) as URL?)
    }

    textLabel?.text = item.title
    detailTextLabel?.text = item.subtitle

    [textLabel, detailTextLabel].forEach { $0?.sizeToFit() }

    textLabel?.sizeToFit()
    detailTextLabel?.sizeToFit()

    item.size.height = preferredViewSize.height
  }
}
