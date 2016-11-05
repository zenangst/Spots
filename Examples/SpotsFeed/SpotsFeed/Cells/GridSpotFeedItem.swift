import UIKit
import Imaginary
import Sugar
import Spots
import Brick

class GridSpotFeedItem : UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 320)
  var item: Item?

  lazy var canvasView: UIView = {
    let view = UIView()
    view.autoresizingMask = [.flexibleWidth]
    view.backgroundColor = UIColor.white
    view.clipsToBounds = true

    return view
    }()

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.black
    label.textAlignment = .left
    label.autoresizingMask = [.flexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 22)
    label.numberOfLines = 2

    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .justified
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 15)
    label.numberOfLines = 0

    return label
    }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.autoresizingMask = [.flexibleWidth]

    return imageView
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
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

  func configure(_ item: inout Item) {
    if !item.image.isEmpty {
      imageView.image = nil
      let url = URL(string: item.image)
      imageView.setImage(url: url)
    }

    titleLabel.attributedText = NSAttributedString(string: item.title.uppercased(),
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    subtitleLabel.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])

    layoutSubviews()
    item.size.height = subtitleLabel.y + subtitleLabel.frame.height + 20

    canvasView.frame = CGRect(x: 10, y: 10,
      width: contentView.frame.width - 20,
      height: item.size.height)

    item.size.height += 20
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.height = 320

    [titleLabel, subtitleLabel].forEach {
      $0.sizeToFit()
      $0.width = contentView.frame.width
    }

    titleLabel.y = 340

    subtitleLabel.y = titleLabel.height + titleLabel.y
  }
}
