import Spots
import Imaginary
import Sugar
import Brick

open class DefaultListSpotCell: UITableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 60)
  open var item: Item?

  lazy var selectedView = UIView()

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
    backgroundColor = UIColor.clear
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    textLabel?.textColor = UIColor.white
    detailTextLabel?.textColor = UIColor.gray

    if let textColor = item.meta("textColor", type: UIColor.self), !textColor.isDark {
      textLabel?.textColor = textColor
    }

    if let background = item.meta("background", type: UIColor.self), !background.isDark {
      textLabel?.textColor = UIColor.darkGray
    }

    if let subtitleColor = item.meta("secondary", type: UIColor.self), !subtitleColor.isDark {
      detailTextLabel?.textColor = subtitleColor

      if let backgroundColor = backgroundColor, !backgroundColor.isDark {
        detailTextLabel?.textColor = UIColor.darkGray
      }
    }

    if let action = item.action, action.isPresent {
      accessoryType = .disclosureIndicator
      selectedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
    } else {
      accessoryType = .none
      selectedView.backgroundColor = UIColor.clear
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if item.image.isPresent {
      imageView?.image = UIImage(named: item.image)?.withRenderingMode(.alwaysTemplate)
      imageView?.tintColor = UIColor.white
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
  }
}
