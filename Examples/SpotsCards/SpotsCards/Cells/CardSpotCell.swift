import UIKit
import Imaginary
import Sugar
import Hue
import Spots
import Brick

class CardSpotCell : UICollectionViewCell, SpotConfigurable {

  var size = CGSize(
    width: 325,
    height: ceil(UIScreen.mainScreen().bounds.height / 1.4))

  lazy var canvasView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    view.clipsToBounds = true
    view.layer.cornerRadius = 8

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
    style.firstLineHeadIndent = 20.0
    style.headIndent = 20.0
    style.tailIndent = -40.0
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

  func configure(inout item: ViewModel) {
    if !item.image.isEmpty {
      imageView.image = nil
      let URL = NSURL(string: item.image)
      imageView.setImage(URL)
    }

    titleLabel.attributedText = NSAttributedString(string: item.title.uppercaseString,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    subtitleLabel.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])

    titleLabel.textColor = UIColor.hex(item.meta.property("foreground-color") ?? "000000")
    subtitleLabel.textColor = UIColor.hex(item.meta.property("foreground-color") ?? "000000")
    canvasView.backgroundColor = UIColor.hex(item.meta.property("background-color") ?? "FFFFFF")

    layoutSubviews()

    canvasView.frame = CGRect(
      x: 0,
      y: 10,
      width: frame.width - CardSpot.padding,
      height: frame.height - CardSpot.padding)

    item.size.height = ceil(UIScreen.mainScreen().bounds.height / 1.4)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    [titleLabel, subtitleLabel].forEach {
      $0.sizeToFit()
      $0.frame.size.width = contentView.frame.width
    }

    titleLabel.frame.origin.y = 30
    subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y
  }
}
