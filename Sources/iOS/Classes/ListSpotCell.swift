import UIKit

/// A boilerplate cell for ListSpot
open class ListSpotCell: UITableViewCell, ItemConfigurable {

  /// The preferred view size for the view, width will be ignored for ListSpot cells
  open var preferredViewSize = CGSize(width: 0, height: 44)
  /// An optional reference to the current item
  open var item: Item?

  /// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
  ///
  /// - parameter style:           A constant indicating a cell style. See UITableViewCellStyle for descriptions of these constants.
  /// - parameter reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
  ///
  /// - returns: An initialized UITableViewCell object or nil if the object could not be created.
  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }

  /// Init with coder
  ///
  /// - parameter aDecoder: An NSCoder
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Configure cell with Item struct
  ///
  /// - parameter item: The Item struct that is used for configuring the view.
  open func configure(_ item: inout Item) {
    if let action = item.action, !action.isEmpty {
      accessoryType = .disclosureIndicator
    } else {
      accessoryType = .none
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title
    imageView?.image = UIImage(named: item.image)

    item.size.height = item.size.height > 0.0 ? item.size.height : preferredViewSize.height
    self.item = item
  }
}
