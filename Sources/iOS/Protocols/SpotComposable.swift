import UIKit
import Brick

/// A protocol used for composition inside Spotable objects
public protocol SpotComposable: class {
  /// A required content view, needed because of SpotComposable extensions
  var contentView: View { get }

  /**
   Configure a SpotComposable with an item and a collection of Spotable objects

   - parameter item:  The Item struct that is SpotComposable
   - parameter spots: A collection of Spotable objects that should be used to configure the child
   */
  func configure(inout item: Item, spots: [Spotable]?)

  /**
   Parse children of an Item into Spotable components

   - parameter item: The item you want to parse

   - returns: A collection of Spotable objects
   */
  func parse(item: Item) -> [Spotable]
}
