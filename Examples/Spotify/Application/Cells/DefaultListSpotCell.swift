import Spots
import Imaginary

public class DefaultListSpotCell: UITableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 60)
  public var item: ListItem?

  lazy var selectedView: UIView = {
    let view = UIView()

    return view
  }()

  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 60, height: 60))

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
    backgroundColor = UIColor.clearColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
    textLabel?.textColor = UIColor.whiteColor()
    detailTextLabel?.textColor = UIColor.grayColor()

    if let textColor = item.meta["textColor"] as? UIColor where !textColor.isDarkColor {
      textLabel?.textColor = textColor
    }

    if let background = item.meta["background"] as? UIColor {
      if !background.isDarkColor {
        textLabel?.textColor = UIColor.darkGrayColor()
      }
    }

    if let subtitleColor = item.meta["secondary"] as? UIColor where !subtitleColor.isDarkColor {
      detailTextLabel?.textColor = subtitleColor

      if let backgroundColor = backgroundColor where !backgroundColor.isDarkColor {
        detailTextLabel?.textColor = UIColor.darkGrayColor()
      }
    }

    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
      selectedView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)
    } else {
      accessoryType = .None
      selectedView.backgroundColor = UIColor.clearColor()
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if !item.image.isEmpty {
      imageView?.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
      imageView?.tintColor = UIColor.whiteColor()
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }
}
