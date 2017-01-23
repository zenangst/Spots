import Brick

// MARK: - SpotsDelegate extension
public extension SpotsDelegate {

  /// Triggered when ever a user taps on an item
  ///
  /// - parameter spot: The spotable object that the item belongs to.
  /// - parameter item: The item struct that the user tapped on.
  func spotable(_ spot: Spotable, itemSelected item: Item) {}

  /// Invoked when ever the collection of spotable objects changes on the Controller.
  ///
  /// - parameter spots: The collection of new Spotable objects.
  func spotablesDidChange(_ spots: [Spotable]) {}

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, willDisplay view: SpotView, item: Item) {}

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: Item) {}
}
