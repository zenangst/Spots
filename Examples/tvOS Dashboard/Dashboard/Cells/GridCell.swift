import UIKit
import Sugar
import Tailor
import Spots
import Brick
import Imaginary

class GridCell: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 160, height: 340)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.adjustsImageWhenAncestorFocused = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {
    if item.image.isPresent {
      imageView.setImage(url: URL(string: item.image))
      imageView.tintColor = UIColor.white
      imageView.frame.size = frame.size
      imageView.width -= 20
      imageView.height -= 20
    } else {
      imageView.image = nil
    }

    if item.size.height == 0.0 {
      item.size.height = preferredViewSize.height
    }

    item.size.height = item.meta("height", item.size.height)
  }

  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      if self.isFocused {
        self.layer.zPosition = 1000
      } else {
        self.layer.zPosition = 0
      }
      }, completion: nil)
  }
}
