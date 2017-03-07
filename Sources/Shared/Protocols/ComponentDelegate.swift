/// A generic delegate for Spots
public protocol ComponentDelegate: class {

  /// A delegate method that is triggered when ever a cell is tapped by the user.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter itemSelected: The data for the view that is going to be displayed.
  func component(_ component: Spotable, itemSelected item: Item)

  /// A delegate method that is triggered when spots is changed.
  ///
  /// - parameter components: New collection of Spotable objects
  func componentsDidChange(_ components: [Spotable])

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Spotable, willDisplay view: SpotView, item: Item)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Spotable, didEndDisplaying view: SpotView, item: Item)
}
