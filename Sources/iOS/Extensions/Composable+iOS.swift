import UIKit
import Brick

// MARK: - An extension on Composable views
public extension Composable where Self : View {

  /// A configuration method to configure the Composable view with a collection of Spotable objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter spots: A collection of Spotable objects created from the children of the item
  func configure(_ item: inout Item, compositeSpots: [CompositeSpot]?) {
    guard let compositeSpots = compositeSpots else {
      return
    }

    var size = contentView.frame.size
    let width = contentView.frame.width
    var height: CGFloat = 0.0

    #if os(tvOS)
      if let tableView = superview?.superview as? UITableView {
        size.width = tableView.frame.size.width
      }
    #endif

    compositeSpots.enumerated().forEach { index, compositeSpot in
      compositeSpot.spot.setup(size)
      compositeSpot.spot.component.size = CGSize(
        width: width,
        height: ceil(compositeSpot.spot.render().frame.size.height))
      compositeSpot.spot.layout(size)
      compositeSpot.spot.render().layoutIfNeeded()

      compositeSpot.spot.render().frame.origin.y = height
      /// Disable scrolling for listable objects
      compositeSpot.spot.render().isScrollEnabled = !(compositeSpot.spot is Listable)
      compositeSpot.spot.render().frame.size.height = compositeSpot.spot.render().contentSize.height

      height += compositeSpot.spot.render().contentSize.height

      contentView.addSubview(compositeSpot.spot.render())
    }

    item.size.height = height
  }
}
