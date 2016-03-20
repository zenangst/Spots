import UIKit
import Sugar
import Tailor
import Spots
import Imaginary
import Hue

class GridTopicCell: UICollectionViewCell, ViewConfigurable {

  var size = CGSize(width: 125, height: 160)

  lazy var label = UILabel().then {
    $0.font = UIFont.boldSystemFontOfSize(11)
    $0.numberOfLines = 2
    $0.textAlignment = .Center
  }

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
  }

  lazy var plusButton: UILabel = { [unowned self] in
    let button = UILabel()
    button.backgroundColor = UIColor.hex("FFF").alpha(0.7)
    button.clipsToBounds = true
    button.frame = CGRect(x: self.size.width - 48, y: 8, width: 25, height: 25)
    button.layer.cornerRadius = button.frame.width / 2
    button.font = UIFont(name: "Menlo", size: 16)
    button.text = "+"
    button.textAlignment = .Center

    return button
  }()

  lazy var blurView = UIVisualEffectView().then {
    $0.effect = UIBlurEffect(style: .ExtraLight)
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Center
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

  func configure(inout item: ViewModel) {
    if !item.image.isEmpty {
      imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      imageView.image = nil
      let URL = NSURL(string: item.image)
      imageView.setImage(URL)
    }

    if let hexColor =  item.meta["color"] as? String {
      contentView.backgroundColor = UIColor.hex(hexColor)
    }

    blurView.frame.size.width = contentView.frame.size.width
    blurView.frame.size.height = 48
    blurView.frame.origin.y = 120

    label.attributedText = NSAttributedString(string: item.title,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.sizeToFit()
    label.frame.size.height = 38
    label.frame.size.width = blurView.frame.width

    item.size.height = 155
  }
}
