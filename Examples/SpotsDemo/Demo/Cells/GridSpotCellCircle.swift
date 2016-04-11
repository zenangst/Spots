import UIKit
import Imaginary
import Sugar
import Spots
import Brick

class GridSpotCellCircle : UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 88, height: 120)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
    return imageView
    }()

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 14)
    label.numberOfLines = 2
    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont.systemFontOfSize(12)
    label.textColor = UIColor(red:0.529, green:0.529, blue:0.529, alpha: 1)
    label.numberOfLines = 0
    return label
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    [titleLabel, subtitleLabel, imageView].forEach{ contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ViewModel) {
    optimize()

    imageView.height = 88

    if !item.image.isEmpty {
      let URL = NSURL(string: item.image)
      imageView.setImage(URL)
    }

    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle

    layoutSubviews()

    item.size.height = subtitleLabel.y + subtitleLabel.height
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.frame = contentView.frame
    imageView.height = 88
    imageView.width = 88
    imageView.x = width / 2 - imageView.width / 2
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 44
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2.0

    titleLabel.sizeToFit()
    titleLabel.width = contentView.width
    titleLabel.y = imageView.y > 88
      ? imageView.y
      : 88
    titleLabel.y += 10

    subtitleLabel.sizeToFit()
    subtitleLabel.width = contentView.width
    subtitleLabel.y = titleLabel.height + titleLabel.y
    subtitleLabel.width = contentView.width
    subtitleLabel.height += 10
  }
}
