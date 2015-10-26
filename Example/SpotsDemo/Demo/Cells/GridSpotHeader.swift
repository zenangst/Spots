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

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    clipsToBounds = true
    
    if !item.image.isEmpty {
      layer.shouldRasterize = true
      layer.rasterizationScale = UIScreen.mainScreen().scale
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
    
    imageView.frame = contentView.frame
    item.size.height = 320
  }
}
