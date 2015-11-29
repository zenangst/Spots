import Spots
import GoldenRetriever
import Sugar

class FeedItemCell: UITableViewCell, Itemble {

  var size = CGSize(width: 0, height: 0)

  lazy var customImageView: UIImageView = {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
    imageView.contentMode = .ScaleAspectFill

    return imageView
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    style.firstLineHeadIndent = 10.0
    style.headIndent = 10.0
    style.tailIndent = 0.0

    return style
    }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

    textLabel?.numberOfLines = 0
    textLabel?.font = UIFont.boldSystemFontOfSize(16)
    detailTextLabel?.numberOfLines = 0
    detailTextLabel?.font = UIFont.systemFontOfSize(13)
    accessoryView = customImageView
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {

    if !item.image.isEmpty {
      dispatch(queue: .Interactive) {
        GoldenRetriever().fetch(item.image) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch { [weak self] in

            self?.customImageView.image = image
          }
        }
      }
    }

    textLabel?.attributedText = NSAttributedString(string: item.title,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    detailTextLabel?.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])

    [textLabel, detailTextLabel].forEach { $0?.sizeToFit() }

    let textFrame = item.title.boundingRectWithSize(frame.size, options: .UsesLineFragmentOrigin, attributes: [NSParagraphStyleAttributeName : paddedStyle], context: nil)
    let detailTextFrame = item.subtitle.boundingRectWithSize(frame.size, options: .UsesLineFragmentOrigin, attributes: [NSParagraphStyleAttributeName : paddedStyle], context: nil)

    item.size.height = textFrame.size.height + detailTextFrame.size.height + 120
  }
}
