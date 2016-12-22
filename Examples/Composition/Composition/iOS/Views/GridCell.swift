import UIKit
import Tailor
import Spots
import Brick
import Imaginary

class GridCell: UICollectionViewCell, SpotConfigurable {

  #if os(iOS)
  var preferredViewSize: CGSize = CGSize(width: 120, height: 80)
  #endif
  
  #if os(tvOS)
  var preferredViewSize: CGSize = CGSize(width: 160, height: 340)
  #endif

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    #if os(tvOS)
    imageView.adjustsImageWhenAncestorFocused = true
    #endif
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {
    if !item.image.isEmpty {
      imageView.setImage(url: URL(string: item.image))
      imageView.tintColor = UIColor.white
      imageView.frame.size = frame.size
      imageView.frame.size.width -= 20
      imageView.frame.size.height -= 20
      imageView.frame.origin.x += 10
      imageView.frame.origin.y += 10
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
