import UIKit
import Tailor
import Spots
import Brick
import Imaginary

class FeaturedCell: UICollectionViewCell, SpotConfigurable {

  #if os(iOS)
    var preferredViewSize: CGSize = CGSize(width: 500, height: 240)
  #endif

  #if os(tvOS)
  var preferredViewSize: CGSize = CGSize(width: 500, height: 500)
  #endif

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    #if os(tvOS)
    imageView.adjustsImageWhenAncestorFocused = true
    #endif
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    imageView.frame.size = frame.size

    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {

    if !item.image.isEmpty {
      imageView.setImage(url: URL(string: item.image))
    } else {
      imageView.image = nil
    }
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
