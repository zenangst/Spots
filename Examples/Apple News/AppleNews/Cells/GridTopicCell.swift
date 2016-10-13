import UIKit
import Sugar
import Tailor
import Spots
import Imaginary
import Hue
import Brick

class GridTopicCell: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 125, height: 160)

  lazy var label = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 11)
    $0.numberOfLines = 2
    $0.textAlignment = .center
  }

  lazy var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }

  lazy var plusButton: UILabel = { [unowned self] in
    let button = UILabel()
    button.backgroundColor = UIColor(hex: "FFF").alpha(0.7)
    button.clipsToBounds = true
    button.frame = CGRect(x: self.preferredViewSize.width - 48, y: 8, width: 25, height: 25)
    button.layer.cornerRadius = button.frame.width / 2
    button.font = UIFont(name: "Menlo", size: 16)
    button.text = "+"
    button.textAlignment = .center

    return button
  }()

  lazy var blurView = UIVisualEffectView().then {
    $0.effect = UIBlurEffect(style: .extraLight)
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .center
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 3

    blurView.contentView.addSubview(label)

    [imageView, plusButton, blurView].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure( _ item: inout Item) {
    if !item.image.isEmpty {
      imageView.frame = CGRect(x: 0, y: 0, width: preferredViewSize.width, height: preferredViewSize.height)
      imageView.image = nil
      let url = URL(string: item.image)
      imageView.setImage(url)
    }

    if let hexColor =  item.meta["color"] as? String {
      contentView.backgroundColor = UIColor(hex: hexColor)
    }

    blurView.width = contentView.width
    blurView.height = 48
    blurView.y = 120

    label.attributedText = NSAttributedString(string: item.title,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.sizeToFit()
    label.height = 38
    label.width = blurView.frame.width

    item.size.height = 155
  }
}
