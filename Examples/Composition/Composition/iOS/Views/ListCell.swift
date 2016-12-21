import Spots
import Brick
import UIKit

extension UIImage {

  static func transparentImage(_ size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}

open class ListCell: UITableViewCell, SpotConfigurable {

  #if os(tvOS)
    open var preferredViewSize: CGSize = CGSize(width: 0, height: 128)
  #endif

  #if os(iOS)
    open var preferredViewSize: CGSize = CGSize(width: 0, height: 67)
  #endif

  open var item: Item?

  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 60, height: 60))

  lazy var selectedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
    return view
  }()

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    textLabel?.textColor = UIColor.black
    detailTextLabel?.textColor = UIColor.black

    if let action = item.action, !action.isEmpty {
      accessoryType = .disclosureIndicator
    } else {
      accessoryType = .none
    }

    if !item.image.isEmpty {
      imageView?.setImage(url: URL(string: item.image), placeholder: transparentImage) { [weak self] _ in
        self?.layoutSubviews()
      }
    } else {
      imageView?.image = nil
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    #if os(tvOS)
      textLabel?.frame.origin.x = 16
      detailTextLabel?.frame.origin.x = 16
      imageView?.frame.origin.x = 24
      imageView?.frame.origin.y = 16
      imageView?.frame.size = CGSize(width: 96, height: 96)
      imageView?.layer.cornerRadius = 96 / 2

      if imageView?.image != nil {
        textLabel?.frame.origin.x = 132
        detailTextLabel?.frame.origin.x = 132
      }
    #endif

    #if os(iOS)
      imageView?.frame.size = CGSize(width: 48, height: 48)
      imageView?.layer.cornerRadius = 48 / 2
      imageView?.frame.origin.y = 12
      textLabel?.frame.origin.x = 72
      detailTextLabel?.frame.origin.x = 72
      separatorInset.left = 72
    #endif

    imageView?.clipsToBounds = true
  }
}
