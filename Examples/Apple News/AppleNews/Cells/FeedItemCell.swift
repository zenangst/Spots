import Spots
import Sugar
import Imaginary
import Brick

class FeedItemCell: UITableViewCell, SpotConfigurable {

  var size = CGSize(width: 0, height: 130)

  lazy var customImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).then {
    $0.contentMode = .ScaleAspectFill
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Left
    $0.firstLineHeadIndent = 5.0
    $0.headIndent = 5.0
    $0.tailIndent = 0.0
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

    textLabel?.numberOfLines = 0
    textLabel?.font = UIFont.boldSystemFontOfSize(16)
    detailTextLabel?.numberOfLines = 0
    detailTextLabel?.font = UIFont.systemFontOfSize(13)
    accessoryView = customImageView

    selectionStyle = .None
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ViewModel) {
    if !item.image.isEmpty {
      customImageView.setImage(NSURL(string: item.image))
    }

    textLabel?.text = item.title
    detailTextLabel?.text = item.subtitle

    [textLabel, detailTextLabel].forEach { $0?.sizeToFit() }

    textLabel?.sizeToFit()
    detailTextLabel?.sizeToFit()

    item.size.height = size.height
  }
}
