import UIKit
import GoldenRetriever
import Sugar

class GridSpotCellCircle : UICollectionViewCell, Itemble {

  var size = CGSize(width: 88, height: 120)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]
    return imageView
    }()

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "Avenir Next", size: 12)
    return label
    }()

  func configure(inout item: ListItem) {
    if item.image != "" {
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

    if imageView.superview == nil {
      contentView.addSubview(imageView)
    }
  }

  override func layoutSubviews() {
    imageView.frame = contentView.frame
    imageView.frame.size.height = 88
    imageView.frame.size.width = 88
    imageView.frame.origin.x = frame.size.width / 2 - imageView.frame.size.width / 2
    imageView.frame.origin.y = frame.size.height / 2 - imageView.frame.size.height / 2
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 44
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2.0
  }

}
