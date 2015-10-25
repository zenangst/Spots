import UIKit
import GoldenRetriever
import Sugar

class GridSpotCellCircle : UICollectionViewCell, Itemble {

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

  func configure(inout item: ListItem) {
    self.imageView.frame.size.height = 88
    if !item.image.isEmpty {
      let resource = item.image
      let fido = GoldenRetriever()
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        fido.fetch(resource) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch {
            self.imageView.image = image
          }
        }
      }
    }
    
    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle

    layoutSubviews()

    item.size.height = subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.frame = contentView.frame
    imageView.frame.size.height = 88
    imageView.frame.size.width = 88
    imageView.frame.origin.x = frame.size.width / 2 - imageView.frame.size.width / 2
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 44
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2.0

    titleLabel.sizeToFit()
    titleLabel.frame.size.width = contentView.frame.width
    titleLabel.frame.origin.y = imageView.frame.origin.y > 88
      ? imageView.frame.origin.y
      : 88
    titleLabel.frame.origin.y += 10

    subtitleLabel.sizeToFit()
    subtitleLabel.frame.size.width = contentView.frame.width
    subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y
    subtitleLabel.frame.size.width = contentView.frame.width
    subtitleLabel.frame.size.height += 10
  }
}
