import Spots
import Imaginary

public class DefaultListSpotCell: UITableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 60)
  public var item: ListItem?

  lazy var selectedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)

    return view
  }()

  lazy var transparentImage: UIImage = {
    return UIImage.transparentImage(CGSize(width: 60, height: 60))
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
    detailTextLabel?.textColor = UIColor.grayColor()

    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
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
