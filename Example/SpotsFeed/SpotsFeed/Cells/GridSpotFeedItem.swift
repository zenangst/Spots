import UIKit
import GoldenRetriever
import Sugar
import Hex

class GridSpotFeedItem : UICollectionViewCell, Itemble {

  var size = CGSize(width: 0, height: 320)
  var item: ListItem?

  lazy var canvasView: UIView = {
    let view = UIView()
    view.autoresizingMask = [.FlexibleWidth]
    view.backgroundColor = UIColor.whiteColor()
    view.clipsToBounds = true
    
    return view
    }()

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Left
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 22)
    label.numberOfLines = 2

    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .Justified
    label.font = UIFont.systemFontOfSize(16)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.font = UIFont.systemFontOfSize(15)
    label.numberOfLines = 0

    return label
    }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]

    return imageView
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    style.firstLineHeadIndent = 10.0
    style.headIndent = 10.0
    style.tailIndent = -30.0

    return style
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(canvasView)

    [imageView, titleLabel, subtitleLabel].forEach { canvasView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    if !item.image.isEmpty {
      imageView.image = nil
      let resource = item.image
      let fido = GoldenRetriever()
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        fido.fetch(resource) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch { [weak self] in
            self?.imageView.image = image
          }
        }
      }
    }

    titleLabel.attributedText = NSAttributedString(string: item.title.uppercaseString,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    subtitleLabel.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])

    layoutSubviews()
    item.size.height = subtitleLabel.frame.origin.y + subtitleLabel.frame.height + 20

    canvasView.frame = CGRect(x: 10, y: 10,
      width: contentView.frame.width - 20,
      height: item.size.height)

    item.size.height += 20
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.frame.size.height = 320

    [titleLabel, subtitleLabel].forEach {
      $0.sizeToFit()
      $0.frame.size.width = contentView.frame.width
    }

    titleLabel.frame.origin.y = 340

    subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y
  }
}
