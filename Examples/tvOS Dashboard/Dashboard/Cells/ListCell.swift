import Spots
import Brick
import UIKit

extension UIImage {

  static func transparentImage(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

public class ListCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 128)
  public var item: Item?

  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 60, height: 60))

  lazy var selectedView = UIView().then {
    $0.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)
  }

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: Item) {
    textLabel?.textColor = UIColor.blackColor()
    detailTextLabel?.textColor = UIColor.blackColor()

    if let action = item.action where action.isPresent {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    if item.image.isPresent {
      imageView?.setImage(NSURL(string: item.image), placeholder: transparentImage)
    } else {
      imageView?.image = nil
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    textLabel?.x = 16
    detailTextLabel?.x = 16

    imageView?.x = 24
    imageView?.y = 16
    imageView?.frame.size = CGSize(width: 96, height: 96)
    imageView?.layer.cornerRadius = 96 / 2

    if imageView?.image != nil {
      textLabel?.x = 132
      detailTextLabel?.x = 132
    }
  }
}
