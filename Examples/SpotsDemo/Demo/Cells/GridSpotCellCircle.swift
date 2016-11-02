import UIKit
import Imaginary
import Sugar
import Spots
import Brick

class GridSpotCellCircle: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 88, height: 140)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    return imageView
    }()

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.black
    label.textAlignment = .center
    label.autoresizingMask = [.flexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 14)
    label.numberOfLines = 2
    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .center
    label.autoresizingMask = [.flexibleWidth]
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor(red:0.529, green:0.529, blue:0.529, alpha: 1)
    label.numberOfLines = 0
    return label
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    [titleLabel, subtitleLabel, imageView].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure( _ item: inout Item) {
    optimize()

    imageView.height = 88

    if !item.image.isEmpty {
      let url = URL(string: item.image)
      imageView.setImage(url: url)
    }

    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle

    layoutSubviews()

    item.size.height = subtitleLabel.frame.maxY
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.frame = contentView.frame
    imageView.height = 88
    imageView.width = 88
    imageView.x = width / 2 - imageView.width / 2
    imageView.y = 20
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = imageView.height / 2
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 2.0

    titleLabel.sizeToFit()
    titleLabel.width = contentView.width
    titleLabel.y = imageView.frame.maxY
    titleLabel.y += 10

    subtitleLabel.sizeToFit()
    subtitleLabel.width = contentView.width
    subtitleLabel.y = titleLabel.frame.maxY
    subtitleLabel.width = contentView.width
    subtitleLabel.height += 10
  }
}
