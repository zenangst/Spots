import UIKit
import Brick

/// A boilerplate cell for ListSpot
public class ListSpotCell: UITableViewCell, SpotConfigurable {

  /// The preferred view size for the view, width will be ignored for ListSpot cells
  public var preferredViewSize = CGSize(width: 0, height: 44)
  /// An optional reference to the current item
  public var item: Item?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  /**
   Returns an object initialized from data in a given unarchiver.

   - parameter coder: An unarchiver object.
   */
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
   A configure method that connects data with the view

   - parameter item: An Item struct
   */
  public func configure(inout item: Item) {
    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title
    imageView?.image = UIImage(named: item.image)

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
    self.item = item
  }
}
