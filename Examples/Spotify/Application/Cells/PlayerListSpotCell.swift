import Spots
import Imaginary
import Brick

public class PlayerListSpotCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 60)
  public var item: ViewModel?

  lazy var selectedView = UIView()
  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 60, height: 60))

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
    backgroundColor = UIColor.clearColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    textLabel?.textAlignment = .Center
    textLabel?.font = UIFont.boldSystemFontOfSize(14)
    detailTextLabel?.font = UIFont.boldSystemFontOfSize(14)
    detailTextLabel?.textAlignment = .Center
    textLabel?.textColor = UIColor.whiteColor()
    detailTextLabel?.textColor = UIColor.grayColor()

    if let action = item.action where action.isPresent {
      accessoryType = .DisclosureIndicator

      if let subtitleColor = item.meta["secondary"] as? UIColor {
        selectedView.backgroundColor = subtitleColor.alpha(0.8)
      } else {
        selectedView.backgroundColor = UIColor.darkGrayColor().alpha(0.8)
      }
    } else {
      accessoryType = .None
      selectedView.backgroundColor = UIColor.clearColor()
    }

    if let textColor = item.meta["textColor"] as? UIColor where !textColor.isDark {
      textLabel?.textColor = textColor
    }

    if let background = item.meta["background"] as? UIColor {
      if !background.isDark {
        textLabel?.textColor = UIColor.darkGrayColor()
      }
    }

    if let subtitleColor = item.meta["secondary"] as? UIColor where !subtitleColor.isDark {
      detailTextLabel?.textColor = subtitleColor

      if let backgroundColor = backgroundColor where !backgroundColor.isDark {
        detailTextLabel?.textColor = UIColor.darkGrayColor()
      }
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if !item.image.isEmpty {
      imageView?.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
      imageView?.tintColor = UIColor.whiteColor()
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }

  public override func layoutSubviews() {
    textLabel?.frame.size = frame.size
    detailTextLabel?.frame.size = frame.size

    textLabel?.y = -10
    detailTextLabel?.y = 10
  }
}
