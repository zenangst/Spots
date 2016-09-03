import UIKit
import Sugar
import Brick

public class ListSpotCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 44)
  public var item: ViewModel?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    if let action = item.action where action.isPresent {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title
    imageView?.image = UIImage(named: item.image)

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }
}
