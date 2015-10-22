import UIKit
import GoldenRetriever
import Sugar

class GridSpotHeader : UICollectionViewCell, Itemble {

  var size = CGSize(width: 0, height: 320)
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]
    return imageView
    }()

  func configure(inout item: ListItem) {
    clipsToBounds = true

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

    imageView.frame = frame

    if imageView.superview == nil {
      contentView.addSubview(imageView)
    }
  }
}
