import UIKit
import GoldenRetriever
import Sugar

class CarouselSpotCell: UICollectionViewCell, Itemble {

  var size = CGSize(width: 88, height: 88)
  var item: ListItem?
  
  var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0,
      width: 200,
      height: 200))
    label.textAlignment = .Center
    return label
    }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.autoresizingMask = [.FlexibleWidth]
    imageView.contentMode = .ScaleAspectFill
    return imageView
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, label].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    if !item.image.isEmpty {
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        GoldenRetriever().fetch(item.image) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch { [weak self] in
            self?.imageView.image = image
          }
        }
      }
    }
    
    imageView.frame = contentView.frame
    label.text = item.title
  }
}
