import UIKit
import Sugar
import Tailor
import Spots
import Brick
import Imaginary

class FeaturedCell: UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 125, height: 500)

  lazy var imageView = UIImageView().then {
    $0.adjustsImageWhenAncestorFocused = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    imageView.frame.size = frame.size

    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: Item) {

    if item.image.isPresent {
      imageView.setImage(NSURL(string: item.image))
    } else {
      imageView.image = nil
    }

    if item.size.height == 0.0 {
      item.size.height = size.height
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      if self.focused {
        self.layer.zPosition = 1000
      } else {
        self.layer.zPosition = 0
      }
      }, completion: nil)
  }
}
