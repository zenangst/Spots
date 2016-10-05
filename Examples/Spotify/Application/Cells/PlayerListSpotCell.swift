import Spots
import Imaginary
import Brick

open class PlayerListSpotCell: UITableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 60)
  open var item: Item?

  lazy var selectedView = UIView()
  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 60, height: 60))

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
    backgroundColor = UIColor.clear
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    textLabel?.textAlignment = .center
    textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    detailTextLabel?.textAlignment = .center
    textLabel?.textColor = UIColor.white
    detailTextLabel?.textColor = UIColor.gray

    if let action = item.action, action.isPresent {
      accessoryType = .disclosureIndicator

      if let subtitleColor = item.meta["secondary"] as? UIColor {
        selectedView.backgroundColor = subtitleColor.alpha(0.8)
      } else {
        selectedView.backgroundColor = UIColor.darkGray.alpha(0.8)
      }
    } else {
      accessoryType = .none
      selectedView.backgroundColor = UIColor.clear
    }

    if let textColor = item.meta["textColor"] as? UIColor, !textColor.isDark {
      textLabel?.textColor = textColor
    }

    if let background = item.meta["background"] as? UIColor {
      if !background.isDark {
        textLabel?.textColor = UIColor.darkGray
      }
    }

    if let subtitleColor = item.meta["secondary"] as? UIColor, !subtitleColor.isDark {
      detailTextLabel?.textColor = subtitleColor

      if let backgroundColor = backgroundColor, !backgroundColor.isDark {
        detailTextLabel?.textColor = UIColor.darkGray
      }
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if !item.image.isEmpty {
      imageView?.image = UIImage(named: item.image)?.withRenderingMode(.alwaysTemplate)
      imageView?.tintColor = UIColor.white
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
  }

  open override func layoutSubviews() {
    textLabel?.frame.size = frame.size
    detailTextLabel?.frame.size = frame.size

    textLabel?.y = -10
    detailTextLabel?.y = 10
  }
}
