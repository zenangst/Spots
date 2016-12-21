import UIKit
import Brick

// MARK: - An extension on Composable views
public extension Composable where Self : View {

  /// A configuration method to configure the Composable view with a collection of Spotable objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter spots: A collection of Spotable objects created from the children of the item
  func configure(_ item: inout Item, spots: [Spotable]?) {
    guard let spots = spots else { return }

    var size = contentView.frame.size
    var width = contentView.frame.width
    var height: CGFloat = 0.0

    #if os(tvOS)
      if let tableView = superview?.superview as? UITableView {
        size.width = tableView.frame.size.width
      }
    #endif

    spots.enumerated().forEach { index, spot in
      spot.component.size = CGSize(
        width: width,
        height: ceil(spot.render().frame.size.height))
      spot.component.size?.height == Optional(0.0)
        ? spot.setup(size)
        : spot.layout(size)

      contentView.addSubview(spot.render())
      spot.render().frame.origin.y = height
      spot.render().layoutIfNeeded()
      /// Disable scrolling for listable objects
      spot.render().isScrollEnabled = !(spot is Listable)
      height += spot.render().contentSize.height
    }

    item.size.height = height
  }

  /// Parse view model children into Spotable objects
  /// - parameter item: A view model with children
  ///
  ///  - returns: A collection of Spotable objects
  public func parse(_ item: Item) -> [Spotable] {
    let spots = Parser.parse(item.children)
    return spots
  }
}
