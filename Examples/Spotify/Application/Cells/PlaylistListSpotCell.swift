import Spots
import Imaginary
import Brick

open class PlaylistListSpotCell: UITableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 60)
  open var item: Item?

  lazy var selectedView = UIView().then {
    $0.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
  }

  lazy var transparentImage = UIImage.transparentImage(CGSize(width: 48, height: 48))

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    backgroundColor = UIColor.black
    textLabel?.textColor = UIColor.white
    detailTextLabel?.textColor = UIColor.white

    if let textColor = item.meta["background"] as? UIColor, !textColor.isDark {
      textLabel?.textColor = textColor
    }

    if let subtitleColor = item.meta["secondary"] as? UIColor, !subtitleColor.isDark {
      detailTextLabel?.textColor = subtitleColor
    }

    if let action = item.action, action.isPresent {
      accessoryType = .disclosureIndicator
    } else {
      accessoryType = .none
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if let url = URL(string: item.image), item.image.isPresent {
      imageView?.setImage(url: url, placeholder: transparentImage)
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    imageView?.y = 6
    imageView?.frame.size = CGSize(width: 48, height: 48)

    if imageView?.image != nil {
      textLabel?.x = 68
      detailTextLabel?.x = 68
    }
  }
}
