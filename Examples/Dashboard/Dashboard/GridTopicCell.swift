import UIKit
import Sugar
import Tailor
import Spots
import Brick

class GridTopicCell: UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 125, height: 320)

  lazy var label = UILabel().then {
    $0.font = UIFont.boldSystemFontOfSize(32)
    $0.numberOfLines = 2
    $0.textAlignment = .Center
  }

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
    $0.adjustsImageWhenAncestorFocused = true
  }

  lazy var blurView = UIVisualEffectView().then {
    $0.effect = UIBlurEffect(style: .ExtraLight)
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Center
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 8

    blurView.contentView.addSubview(label)

    [imageView, blurView].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ViewModel) {
    contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
    blurView.width = contentView.width
    blurView.height = 88
    blurView.y = size.height - blurView.height

    label.attributedText = NSAttributedString(string: item.title,
                                              attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.sizeToFit()
    label.frame.origin.y = 20
    label.height = 38
    label.width = blurView.frame.width

    if item.size.height == 0.0 {
      item.size.height = size.height
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      if self.focused {
        self.transform = CGAffineTransformMakeScale(1.1, 1.1)
      } else {
        self.transform = CGAffineTransformIdentity
      }
      }, completion: nil)
  }
}
