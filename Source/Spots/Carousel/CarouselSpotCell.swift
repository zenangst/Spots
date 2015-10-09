import UIKit
import GoldenRetriever
import Sugar

class CarouselSpotCell: UICollectionViewCell, Gridable {

  var size = CGSize(width: 88, height: 88)
  var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0,
      width: 200,
      height: 200))
    label.textAlignment = .Center
    return label
    }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]
    return imageView
    }()

  func configure(item: ListItem) {
    if !item.image.isEmpty {
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        GoldenRetriever().fetch(item.image) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch {
            self.imageView.image = image
          }
        }
      }
    } else {
      backgroundColor = UIColor.lightGrayColor()
    }

    if imageView.superview == nil {
      imageView.frame = contentView.frame
      contentView.addSubview(imageView)
    }

    label.text = item.title

    if label.superview == nil {
      contentView.addSubview(label)
    }
  }
}
