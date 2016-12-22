import Brick
import Cocoa

// MARK: - An extension on Composable views
public extension Composable {

  /// A configuration method to configure the Composable view with a collection of Spotable objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter spots: A collection of Spotable objects created from the children of the item
  func configure(_ item: inout Item, spots: [Spotable]?) {
    guard let spots = spots else { return }

    let size = contentView.frame.size
    let width = contentView.frame.width
    var height: CGFloat = 0.0

    spots.enumerated().forEach { index, spot in
      spot.component.size = CGSize(
        width: width,
        height: ceil(spot.render().frame.size.height))
      spot.component.size?.height == Optional(0.0)
        ? spot.setup(size)
        : spot.layout(size)

      contentView.addSubview(spot.render())
      spot.render().frame.origin.y = height
      spot.render().frame.size.width = contentView.frame.size.width
      spot.render().frame.size.height = spot.render().contentSize.height
      height += spot.render().contentSize.height

      (spot as? Gridable)?.layout.invalidateLayout()
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
