import UIKit
import Imaginary
import Sugar
import Spots
import Brick

class GridSpotHeader: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 320)
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure( _ item: inout Item) {
    optimize()

    if !item.image.isEmpty {
      imageView.image = nil
      let url = NSURL(string: item.image)
      imageView.setImage(url as URL?)
    }

    imageView.frame = contentView.frame
    item.size.height = 320
    item.size.width = UIScreen.main.bounds.width
  }
}
