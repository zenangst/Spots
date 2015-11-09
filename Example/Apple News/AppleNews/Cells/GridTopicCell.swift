import UIKit
import GoldenRetriever
import Sugar
import Tailor
import Hex

class GridTopicCell: UICollectionViewCell, Itemble {

  var size = CGSize(width: 125, height: 160)
  
  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.boldSystemFontOfSize(11)
    label.numberOfLines = 4
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]

    return label
    }()
    
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]

    return imageView
    }()

  lazy var plusButton: UILabel = { [unowned self] in
    let button = UILabel()
    button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    button.clipsToBounds = true
    button.frame = CGRect(x: self.size.width - 48, y: 8, width: 25, height: 25)
    button.layer.cornerRadius = button.frame.width / 2
    button.font = UIFont(name: "Menlo", size: 16)
    button.text = "+"
    button.textAlignment = .Center

    return button
  }()

  lazy var blurView: UIVisualEffectView = {
    let view = UIVisualEffectView()
    view.effect = UIBlurEffect(style: .Light)

    return view
  }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Center

    return style
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 3

    blurView.addSubview(label)

    [imageView, plusButton, blurView].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    if !item.image.isEmpty {
      imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      rasterize()
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
  
    contentView.backgroundColor = UIColor(hex: item.meta.property("background-color") ?? "EEEEEE")

    label.attributedText = NSAttributedString(string: item.title,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.frame.size.height = 38

    blurView.frame.size.width = contentView.frame.size.width
    blurView.frame.size.height = 48
    blurView.frame.origin.y = 120
  }
}
