import Spots
import Imaginary

public class PlaylistListSpotCell: UITableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 60)
  public var item: ListItem?

  lazy var selectedView = UIView().then {
    $0.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)
  }

  lazy var transparentImage: UIImage = {
    return UIImage.transparentImage(CGSize(width: 48, height: 48))
  }()

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
    backgroundColor = UIColor.blackColor()
    textLabel?.textColor = UIColor.whiteColor()
    detailTextLabel?.textColor = UIColor.whiteColor()
    
    if let textColor = item.meta["background"] as? UIColor where !textColor.isDarkColor {
      textLabel?.textColor = textColor
    }

    if let subtitleColor = item.meta["secondary"] as? UIColor where !subtitleColor.isDarkColor {
      detailTextLabel?.textColor = subtitleColor
    }

    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if let url = NSURL(string: item.image) where !item.image.isEmpty {
      imageView?.setImage(url, placeholder: transparentImage)
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    imageView?.frame.origin.y = 6
    imageView?.frame.size = CGSize(width: 48, height: 48)

    if imageView?.image != nil {
      textLabel?.frame.origin.x = 68
      detailTextLabel?.frame.origin.x = 68
    }
  }
}
