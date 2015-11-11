import UIKit

public class ListSpotCell: UITableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 44)
  public var item: ListItem?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
    accessoryType = item.urn?.isEmpty ?? false
      ? .DisclosureIndicator
      : .None
    textLabel?.text = item.title
    detailTextLabel?.text = item.subtitle
    item.size.height = size.height
  }
}
