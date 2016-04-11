import Spots
import Imaginary
import Sugar
import Brick

public class DefaultListSpotCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 60)
  public var item: ViewModel?

  lazy var selectedView = UIView()

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
    backgroundColor = UIColor.clearColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    textLabel?.textColor = UIColor.whiteColor()
    detailTextLabel?.textColor = UIColor.grayColor()

    if let textColor = item.meta("textColor", type: UIColor.self) where !textColor.isDark {
      textLabel?.textColor = textColor
    }

    if let background = item.meta("background", type: UIColor.self) where !background.isDark {
      textLabel?.textColor = UIColor.darkGrayColor()
    }

    if let subtitleColor = item.meta("secondary", type: UIColor.self) where !subtitleColor.isDark {
      detailTextLabel?.textColor = subtitleColor

      if let backgroundColor = backgroundColor where !backgroundColor.isDark {
        detailTextLabel?.textColor = UIColor.darkGrayColor()
      }
    }

    if let action = item.action where action.isPresent {
      accessoryType = .DisclosureIndicator
      selectedView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)
    } else {
      accessoryType = .None
      selectedView.backgroundColor = UIColor.clearColor()
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if item.image.isPresent {
      imageView?.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
      imageView?.tintColor = UIColor.whiteColor()
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }
}
