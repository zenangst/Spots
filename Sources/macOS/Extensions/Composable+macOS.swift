import Brick
import Cocoa

// MARK: - An extension on Composable views
public extension Composable {

  /// A configuration method to configure the Composable view with a collection of Spotable objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter spots: A collection of Spotable objects created from the children of the item
  func configure(_ item: inout Item, compositeSpots: [CompositeSpot]?) {
    guard let compositeSpots = compositeSpots else {
      return
    }

    let size = contentView.frame.size
    let width = contentView.frame.width
    var height: CGFloat = 0.0

    compositeSpots.enumerated().forEach { _, compositeSpot in
      compositeSpot.spot.setup(size)
      compositeSpot.spot.layout(size)

      compositeSpot.spot.component.size = CGSize(
        width: width,
        height: ceil(compositeSpot.spot.view.frame.size.height))

      compositeSpot.spot.view.frame.origin.y = height
      compositeSpot.spot.view.frame.size.width = contentView.frame.size.width
      compositeSpot.spot.view.frame.size.height = compositeSpot.spot.view.contentSize.height

      height += compositeSpot.spot.view.contentSize.height

      (compositeSpot.spot as? Gridable)?.layout.invalidateLayout()

      contentView.addSubview(compositeSpot.spot.view)
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
