import UIKit
import Brick

// MARK: - An extension on SpotComposable views
public extension SpotComposable where Self : View {

  /**
   A configuration method to configure the SpotComposable view with a collection of Spotable objects

   - parameter item:  The item that is currently being configured in the list
   - parameter spots: A collection of Spotable objects created from the children of the item
   */
  func configure(inout item: ViewModel, spots: [Spotable]?) {
    guard let spots = spots else { return }

    var height: CGFloat = 0.0

    spots.enumerate().forEach { index, spot in
      spot.component.size = CGSize(
        width: contentView.frame.width,
        height: ceil(spot.render().frame.size.height))

      spot.component.size?.height == Optional(0.0)
        ? spot.setup(contentView.frame.size)
        : spot.layout(contentView.frame.size)

      contentView.addSubview(spot.render())
      spot.render().frame.origin.y = height
      spot.render().layoutIfNeeded()
      height += spot.render().contentSize.height
    }

    item.size.height = height
  }

  /**
   Parse view model children into Spotable objects

   - parameter item: A view model with children

   - returns: A collection of Spotable objects
   */
  public func parse(item: ViewModel) -> [Spotable] {
    let spots = Parser.parse(item.children)
    return spots
  }
}
