import Spots
import Brick
import UIKit

public class ListCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 88)
  public var item: ViewModel?

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

  public func configure(inout item: ViewModel) {
    textLabel?.textColor = UIColor.blackColor()
    detailTextLabel?.textColor = UIColor.blackColor()

    if let action = item.action where action.isPresent {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    textLabel?.x = 16
    detailTextLabel?.x = 16
  }
}
